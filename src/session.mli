type cfg_op =
    | CfgSet of string list * string option * Config_tree.value_behaviour
    | CfgDelete of string list * string option

type session_data = {
    id: string;
    running_config: Config_tree.t ref;
    proposed_config: Config_tree.t ref;
    reference_tree: Reference_tree.t ref;
    validators: (string, string) Hashtbl.t;
    modified: bool;
    changeset: cfg_op list
}

val make : string -> Config_tree.t ref -> Reference_tree.t ref -> (string, string) Hashtbl.t -> session_data

