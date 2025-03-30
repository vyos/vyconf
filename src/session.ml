module CT = Vyos1x.Config_tree
module VT = Vyos1x.Vytree
module RT = Vyos1x.Reference_tree
module CC = Commitd_client.Commit
module VC = Commitd_client.Vycall_client
module D = Directories

exception Session_error of string

type cfg_op =
    | CfgSet of string list * string option * CT.value_behaviour
    | CfgDelete of string list * string	option

type world = {
    mutable running_config: CT.t;
    mutable reference_tree: RT.t;
    vyconf_config: Vyconf_config.t;
    dirs: Directories.t
}

type session_data = {
    proposed_config : CT.t;
    modified: bool;
    conf_mode: bool;
    changeset: cfg_op list;
    client_app: string;
    user: string;
}

let make world client_app user = {
    proposed_config = world.running_config;
    modified = false;
    conf_mode = false;
    changeset = [];
    client_app = client_app;
    user = user
}

let string_of_op op =
    match op with
    | CfgSet (path, value, _) ->
        let path_str = Vyos1x.Util.string_of_list path in
        (match value with
         | None -> Printf.sprintf "set %s" path_str
         | Some v -> Printf.sprintf "set %s \"%s\"" path_str v)
    | CfgDelete (path, value) ->
        let path_str = Vyos1x.Util.string_of_list path in
        (match value with
         | None -> Printf.sprintf "delete %s" path_str
         | Some v -> Printf.sprintf "delete %s \"%s\"" path_str v)


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

let validate w _s path =
    try
        RT.validate_path D.(w.dirs.validators) w.reference_tree path
    with RT.Validation_error x -> raise (Session_error x)

let split_path w _s path =
    RT.split_path w.reference_tree path

let set w s path =
    let _ = validate w s path in
    let path, value = split_path w s path in
    let refpath = RT.refpath w.reference_tree path in
    let value_behaviour = if RT.is_multi w.reference_tree refpath then CT.AddValue else CT.ReplaceValue in
    let op = CfgSet (path, value, value_behaviour) in
    let config = apply_cfg_op op s.proposed_config in
    {s with proposed_config=config; changeset=(op :: s.changeset)}

let delete w s path =
    let _ = validate w s path in
    let path, value = split_path w s path in
    let op = CfgDelete (path, value) in
    let config = apply_cfg_op op s.proposed_config in
    {s with proposed_config=config; changeset=(op :: s.changeset)}

let commit w s t =
    let at = w.running_config in
    let wt = s.proposed_config in
    let rt = w.reference_tree in
    let commit_data = CC.make_commit_data rt at wt t in
    let received_commit_data = VC.do_commit commit_data in
    let result_commit_data =
        try
            CC.commit_update received_commit_data
        with CC.Commit_error e ->
            raise (Session_error (Printf.sprintf "Commit internal error: %s" e))
    in
    w.running_config <- result_commit_data.config_result;
    result_commit_data.result.success, result_commit_data.result.out

let get_value w s path =
    if not (VT.exists s.proposed_config path) then
        raise (Session_error ("Config path does not exist"))
    else let refpath = RT.refpath w.reference_tree path in
    if not (RT.is_leaf w.reference_tree refpath) then
        raise (Session_error "Cannot get a value of a non-leaf node")
    else if (RT.is_multi w.reference_tree refpath) then
        raise (Session_error "This node can have more than one value")
    else if (RT.is_valueless w.reference_tree refpath) then
        raise (Session_error "This node can have more than one value")
    else CT.get_value s.proposed_config path

let get_values w s path =
    if not (VT.exists s.proposed_config path) then
        raise (Session_error ("Config path does not exist"))
    else let refpath = RT.refpath w.reference_tree path in
    if not (RT.is_leaf w.reference_tree refpath) then
        raise (Session_error "Cannot get a value of a non-leaf node")
    else if not (RT.is_multi w.reference_tree refpath) then
        raise (Session_error "This node can have only one value")
    else CT.get_values s.proposed_config path

let list_children w s path =
    if not (VT.exists s.proposed_config path) then
        raise (Session_error ("Config path does not exist"))
    else let refpath = RT.refpath w.reference_tree path in
    if (RT.is_leaf w.reference_tree refpath) then
        raise (Session_error "Cannot list children of a leaf node")
    else VT.children_of_path s.proposed_config path

let exists _w s path =
    VT.exists s.proposed_config path

let show_config _w s path fmt =
    let open Vyconf_connect.Vyconf_pbt in
    if (path <> []) && not (VT.exists s.proposed_config path) then
        raise (Session_error ("Path does not exist")) 
    else
        let node = s.proposed_config in
        match fmt with
        | Curly -> CT.render_at_level node path
        | Json ->
            let node =
                (match path with [] -> s.proposed_config |
                                 _ as ps -> VT.get s.proposed_config ps) in
            CT.to_yojson node |> Yojson.Safe.pretty_to_string
