type cfg_op =
    | CfgSet of string list * string option * Vyos1x.Config_tree.value_behaviour
    | CfgDelete of string list * string option

type world = {
    mutable running_config: Vyos1x.Config_tree.t;
    mutable reference_tree: Vyos1x.Reference_tree.t;
    vyconf_config: Vyconf_config.t;
    dirs: Directories.t
}

type session_data = {
    proposed_config : Vyos1x.Config_tree.t;
    modified: bool;
    conf_mode: bool;
    changeset: cfg_op list;
    client_app: string;
    user: string
}

exception Session_error of string

val make : world -> string -> string -> session_data

val set_modified : session_data -> session_data

val apply_changes : cfg_op list -> Vyos1x.Config_tree.t -> Vyos1x.Config_tree.t

val validate : world -> session_data -> string list -> unit

val set : world -> session_data -> string list -> session_data

val delete : world -> session_data -> string list -> session_data

val get_value : world -> session_data -> string list -> string

val get_values : world -> session_data -> string list -> string list

val exists : world -> session_data -> string list -> bool

val list_children : world -> session_data -> string list -> string list

val string_of_op : cfg_op -> string

val show_config : world -> session_data -> string list -> Vyconf_connect.Vyconf_pbt.request_config_format -> string
