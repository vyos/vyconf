type cfg_op =
    | CfgSet of string list * string option * Vyos1x.Config_tree.value_behaviour
    | CfgDelete of string list * string option

type world = {
    mutable running_config: Vyos1x.Config_tree.t;
    mutable reference_tree: Vyos1x.Reference_tree.t;
    vyconf_config: Vyconf_config.t;
    dirs: Directories.t
}

type aux_op = {
    script_name: string;
    tag_value: string option;
    changeset: cfg_op list;
} [@@deriving yojson]

type session_data = {
    modified: bool;
    conf_mode: bool;
    changeset: cfg_op list;
    mutable aux_changeset: aux_op list;
    edit_level: string list;
    client_app: string;
    client_pid: int32;
    client_user: string;
    client_sudo_user: string;
} [@@deriving yojson]

exception Session_error of string

val sprint_changeset : aux_op list -> string

val make : world -> string -> string -> string -> int32 -> session_data

val set_modified : session_data -> session_data

val validate : world -> session_data -> string list -> unit

val get_changeset : world -> session_data -> Vyos1x.Config_tree.t -> Vyos1x.Config_tree.t -> cfg_op list

val set : world -> session_data -> string list -> session_data

val delete : world -> session_data -> string list -> session_data

val aux_set : world -> session_data -> string list -> string -> string option -> unit

val aux_delete : world -> session_data -> string list -> string -> string option -> unit

val get_proposed_config : world -> session_data -> Vyos1x.Config_tree.t

val discard : world -> session_data -> session_data

val set_edit_level : world -> session_data -> string list -> session_data * string

val set_edit_level_up : world -> session_data -> session_data * string

val get_edit_level : world -> session_data -> string

val reset_edit_level : world -> session_data -> session_data * string

val edit_level_root : world -> session_data -> bool

val session_changed : world -> session_data -> bool

val load : world -> session_data -> string -> bool -> session_data

val merge : world -> session_data -> string -> bool -> session_data

val save : world -> session_data -> string -> session_data

val config_unsaved : world -> session_data -> string -> string -> bool

val get_value : world -> session_data -> string list -> string

val get_values : world -> session_data -> string list -> string list

val exists : world -> session_data -> string list -> bool

val list_children : world -> session_data -> string list -> string list

val string_of_op : cfg_op -> string

val write_running_cache : world -> (unit, string) result

val write_session_cache : world -> Vyos1x.Config_tree.t -> (unit, string) result

val prepare_commit : ?dry_run:bool -> world -> session_data -> Vyos1x.Config_tree.t -> string -> (Commitd_client.Commit.commit_data, string) result

val post_process_commit : world -> session_data -> Commitd_client.Commit.commit_data * Vyos1x.Config_tree.t -> Vyos1x.Config_tree.t * Vyos1x.Config_tree.t

val get_config : world -> session_data -> string -> string

val cleanup_config : world -> string -> unit

val show_config : world -> session_data -> string list -> string

val reference_path_exists : world -> session_data -> string list -> bool

val get_path_type : ?legacy_format:bool -> world -> session_data -> string list -> string

val get_completion_env : ?legacy_format:bool -> world -> session_data -> string list -> string

val copy : world -> session_data -> string list -> string list -> session_data

val rename : world -> session_data -> string list -> string list -> session_data
