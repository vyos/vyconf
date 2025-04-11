type t

val create : ?token:(string option) -> string -> Vyconf_connect.Vyconf_pbt.request_output_format -> Vyconf_connect.Vyconf_pbt.request_config_format -> t Lwt.t

val get_token : t -> (string, string) result Lwt.t

val shutdown : t -> t Lwt.t

val prompt : t -> Vyconf_connect.Vyconf_pbt.response Lwt.t

val setup_session : ?on_behalf_of:(int option) -> t -> string -> (t, string) result Lwt.t

val teardown_session : ?on_behalf_of:(int option) -> t -> (string, string) result Lwt.t

val exists : t -> string list -> (string, string) result Lwt.t

val get_value : t -> string list -> (string, string) result Lwt.t

val get_values : t -> string list -> (string, string) result Lwt.t

val list_children : t -> string list -> (string, string) result Lwt.t

val show_config : t -> string list -> (string, string) result Lwt.t

val validate : t -> string list -> (string, string) result Lwt.t

val set : t -> string list -> (string, string) result Lwt.t

val delete : t -> string list -> (string, string) result Lwt.t

val commit : t -> (string, string) result Lwt.t


val reload_reftree : ?on_behalf_of:(int option) -> t -> (string, string) result Lwt.t
