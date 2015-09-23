module CT = Config_tree

type cfg_op =
    | CfgSet of string list * string option * CT.value_behaviour
    | CfgDelete of string list * string	option

type session_data = {
    id: string;
    running_config: Config_tree.t ref;
    proposed_config : Config_tree.t ref;
    reference_tree: Reference_tree.t ref;
    validators: (string, string) Hashtbl.t;
    modified: bool;
    changeset: cfg_op list
}

let make i c r v = {
    id = i;
    running_config = c;
    proposed_config = c;
    reference_tree = r;
    validators = v;
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

