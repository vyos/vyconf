type cfg_op =
    | CfgSet of string list * string option * Config_tree.value_behaviour
    | CfgDelete of string list * string option

type world = {
    mutable running_config: Config_tree.t;
    reference_tree: Reference_tree.t;
    validators: (string, string) Hashtbl.t;
}

type session_data = {
    proposed_config : Config_tree.t;
    modified: bool;
    changeset: cfg_op list
}

val make : world -> session_data

val set : world -> session_data -> string list -> session_data

val delete : world -> session_data -> string list -> session_data
