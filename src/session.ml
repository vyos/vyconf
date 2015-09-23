module CT = Config_tree
module RT = Reference_tree

type cfg_op =
    | CfgSet of string list * string option * CT.value_behaviour
    | CfgDelete of string list * string	option

type world = {
    mutable running_config: CT.t;
    reference_tree: RT.t;
    validators: (string, string) Hashtbl.t;
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
