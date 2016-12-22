val panic : string -> 'a

val setup_logger : bool -> string option -> Lwt_log.template -> unit Lwt.t

val load_config : string -> Vyconf_config.t

val check_dirs : Directories.t -> unit
