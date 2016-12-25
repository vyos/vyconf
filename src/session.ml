module CT = Config_tree
module RT = Reference_tree
module D = Directories

exception Session_error of string

type cfg_op =
    | CfgSet of string list * string option * CT.value_behaviour
    | CfgDelete of string list * string	option

type world = {
    mutable running_config: CT.t;
    reference_tree: RT.t;
    vyconf_config: Vyconf_config.t;
    dirs: Directories.t
}

type session_data = {
    proposed_config : Config_tree.t;
    modified: bool;
    changeset: cfg_op list
}

let make world = {
    proposed_config = world.running_config;
    modified = false;
    changeset = []
}

let set_modified s =
    if s.modified = true then s
    else {s with modified = true}

let apply_cfg_op op config =
    match op with
    | CfgSet (path, value, value_behaviour) ->
        CT.set config path value value_behaviour
    | CfgDelete (path, value) -> 
        CT.delete config path value

let rec apply_changes changeset config =
    match changeset with
    | [] -> config
    | c :: cs -> apply_changes cs (apply_cfg_op c config)

let set w s path =
    let path, value = RT.validate_path D.(w.dirs.validators) w.reference_tree path in
    let value_behaviour = if RT.is_multi w.reference_tree path then CT.AddValue else CT.ReplaceValue in
    let op = CfgSet (path, value, value_behaviour) in
    let config = apply_cfg_op op s.proposed_config in
    {s with proposed_config=config; changeset=(op :: s.changeset)}

let delete w s path =
    let path, value = RT.validate_path D.(w.dirs.validators) w.reference_tree path in
    let op = CfgDelete (path, value) in
    let config = apply_cfg_op op s.proposed_config in
    {s with proposed_config=config; changeset=(op :: s.changeset)}

let get_value w s path =
    let path, _ = RT.validate_path D.(w.dirs.validators) w.reference_tree path in
    if RT.is_leaf w.reference_tree path then
        if not ((RT.is_multi w.reference_tree path) || (RT.is_valueless w.reference_tree path))
        then CT.get_value s.proposed_config path
        else raise (Session_error "This node can have more than one value")
    else raise (Session_error "Cannot get a value of a non-leaf node")

let get_values w s path =
    let path, _ = RT.validate_path D.(w.dirs.validators) w.reference_tree path in
    if RT.is_leaf w.reference_tree path then
        if RT.is_multi w.reference_tree path
        then CT.get_values s.proposed_config path
        else raise (Session_error "This node can have only one value")
    else raise (Session_error "Cannot get a value of a non-leaf node")

let list_children w s path =
    let path, _ = RT.validate_path D.(w.dirs.validators) w.reference_tree path in
    if not (RT.is_leaf w.reference_tree path)
    then Vytree.children_of_path s.proposed_config path
    else raise (Session_error "Cannot list children of a leaf node")

let exists w s path =
    let path, _ = RT.validate_path D.(w.dirs.validators) w.reference_tree path in
    Vytree.exists s.proposed_config path
