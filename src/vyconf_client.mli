type t

type status =
  | Success 
  | Fail 
  | Invalid_path 
  | Invalid_value 
  | Commit_in_progress 
  | Configuration_locked 
  | Internal_error 
  | Permission_denied 
  | Path_already_exists 

type response = {
  status : status;
  output : string option;
  error : string option;
  warning : string option;
}


val create : ?token:(string option) -> string -> Vyconf_connect.Vyconf_pbt.request_output_format -> Vyconf_connect.Vyconf_pbt.request_config_format -> t Lwt.t

val get_token : t -> (string, string) result Lwt.t

val shutdown : t -> t Lwt.t

val get_status : t -> response Lwt.t

val setup_session : ?on_behalf_of:(int option) -> t -> string -> (t, string) result Lwt.t

val exists : t -> string list -> (string, string) result Lwt.t

val get_value : t -> string list -> (string, string) result Lwt.t

val get_values : t -> string list -> (string, string) result Lwt.t

val list_children : t -> string list -> (string, string) result Lwt.t

val show_config : t -> string list -> (string, string) result Lwt.t

val validate : t -> string list -> (string, string) result Lwt.t
