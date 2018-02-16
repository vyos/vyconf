type cfg_op =
    | CfgSet of string list * string option * Config_tree.value_behaviour
    | CfgDelete of string list * string option

type world = {
    running_config: Config_tree.t;
    reference_tree: Reference_tree.t;
    vyconf_config: Vyconf_config.t;
    dirs: Directories.t
}

type session_data = {
    proposed_config : Config_tree.t;
    modified: bool;
    conf_mode: bool;
    changeset: cfg_op list;
    client_app: string;
    user: string
}

exception Session_error of string

val make : world -> string -> string -> session_data

val set : world -> session_data -> string list -> session_data

val delete : world -> session_data -> string list -> session_data

val get_value : world -> session_data -> string list -> string

val get_values : world -> session_data -> string list -> string list

val exists : world -> session_data -> string list -> bool

val list_children : world -> session_data -> string list -> string list

val string_of_op : cfg_op -> string

val show_config : world -> session_data -> string list -> Vyconf_types.request_config_format -> string
