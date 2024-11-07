open Vyos1x

val cstore_handle_init : unit -> int
val cstore_handle_free : int -> unit
val cstore_in_config_session_handle : int -> bool
val cstore_in_config_session : unit -> bool
val cstore_set_path : int -> string list -> string
val legacy_validate_path : int -> string list -> string
val legacy_set_path : int -> string list -> string
val cstore_delete_path : int -> string list -> string
val set_path_reversed : int -> string list -> int -> string
val delete_path_reversed : int -> string list -> int -> string

val vyconf_validate_path : string list -> string option

val load_config : Config_tree.t -> Config_tree.t -> string
