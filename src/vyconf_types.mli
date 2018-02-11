(** vyconf.proto Types *)



(** {2 Types} *)

type request_config_format =
  | Curly 
  | Json 

type request_output_format =
  | Out_plain 
  | Out_json 

type request_setup_session = {
  client_application : string option;
  on_behalf_of : int32 option;
}

type request_set = {
  path : string list;
  ephemeral : bool option;
}

type request_delete = {
  path : string list;
}

type request_rename = {
  edit_level : string list;
  from : string;
  to_ : string;
}

type request_copy = {
  edit_level : string list;
  from : string;
  to_ : string;
}

type request_comment = {
  path : string list;
  comment : string;
}

type request_commit = {
  confirm : bool option;
  confirm_timeout : int32 option;
  comment : string option;
}

type request_rollback = {
  revision : int32;
}

type request_load = {
  location : string;
  format : request_config_format option;
}

type request_merge = {
  location : string;
  format : request_config_format option;
}

type request_save = {
  location : string;
  format : request_config_format option;
}

type request_show_config = {
  path : string list;
  format : request_config_format option;
}

type request_exists = {
  path : string list;
}

type request_get_value = {
  path : string list;
  output_format : request_output_format option;
}

type request_get_values = {
  path : string list;
  output_format : request_output_format option;
}

type request_list_children = {
  path : string list;
  output_format : request_output_format option;
}

type request_run_op_mode = {
  path : string list;
  output_format : request_output_format option;
}

type request_enter_configuration_mode = {
  exclusive : bool;
  override_exclusive : bool;
}

type request =
  | Status
  | Setup_session of request_setup_session
  | Set of request_set
  | Delete of request_delete
  | Rename of request_rename
  | Copy of request_copy
  | Comment of request_comment
  | Commit of request_commit
  | Rollback of request_rollback
  | Merge of request_merge
  | Save of request_save
  | Show_config of request_show_config
  | Exists of request_exists
  | Get_value of request_get_value
  | Get_values of request_get_values
  | List_children of request_list_children
  | Run_op_mode of request_run_op_mode
  | Confirm
  | Configure of request_enter_configuration_mode
  | Exit_configure
  | Teardown of string

type request_envelope = {
  token : string option;
  request : request;
}

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


(** {2 Default values} *)

val default_request_config_format : unit -> request_config_format
(** [default_request_config_format ()] is the default value for type [request_config_format] *)

val default_request_output_format : unit -> request_output_format
(** [default_request_output_format ()] is the default value for type [request_output_format] *)

val default_request_setup_session : 
  ?client_application:string option ->
  ?on_behalf_of:int32 option ->
  unit ->
  request_setup_session
(** [default_request_setup_session ()] is the default value for type [request_setup_session] *)

val default_request_set : 
  ?path:string list ->
  ?ephemeral:bool option ->
  unit ->
  request_set
(** [default_request_set ()] is the default value for type [request_set] *)

val default_request_delete : 
  ?path:string list ->
  unit ->
  request_delete
(** [default_request_delete ()] is the default value for type [request_delete] *)

val default_request_rename : 
  ?edit_level:string list ->
  ?from:string ->
  ?to_:string ->
  unit ->
  request_rename
(** [default_request_rename ()] is the default value for type [request_rename] *)

val default_request_copy : 
  ?edit_level:string list ->
  ?from:string ->
  ?to_:string ->
  unit ->
  request_copy
(** [default_request_copy ()] is the default value for type [request_copy] *)

val default_request_comment : 
  ?path:string list ->
  ?comment:string ->
  unit ->
  request_comment
(** [default_request_comment ()] is the default value for type [request_comment] *)

val default_request_commit : 
  ?confirm:bool option ->
  ?confirm_timeout:int32 option ->
  ?comment:string option ->
  unit ->
  request_commit
(** [default_request_commit ()] is the default value for type [request_commit] *)

val default_request_rollback : 
  ?revision:int32 ->
  unit ->
  request_rollback
(** [default_request_rollback ()] is the default value for type [request_rollback] *)

val default_request_load : 
  ?location:string ->
  ?format:request_config_format option ->
  unit ->
  request_load
(** [default_request_load ()] is the default value for type [request_load] *)

val default_request_merge : 
  ?location:string ->
  ?format:request_config_format option ->
  unit ->
  request_merge
(** [default_request_merge ()] is the default value for type [request_merge] *)

val default_request_save : 
  ?location:string ->
  ?format:request_config_format option ->
  unit ->
  request_save
(** [default_request_save ()] is the default value for type [request_save] *)

val default_request_show_config : 
  ?path:string list ->
  ?format:request_config_format option ->
  unit ->
  request_show_config
(** [default_request_show_config ()] is the default value for type [request_show_config] *)

val default_request_exists : 
  ?path:string list ->
  unit ->
  request_exists
(** [default_request_exists ()] is the default value for type [request_exists] *)

val default_request_get_value : 
  ?path:string list ->
  ?output_format:request_output_format option ->
  unit ->
  request_get_value
(** [default_request_get_value ()] is the default value for type [request_get_value] *)

val default_request_get_values : 
  ?path:string list ->
  ?output_format:request_output_format option ->
  unit ->
  request_get_values
(** [default_request_get_values ()] is the default value for type [request_get_values] *)

val default_request_list_children : 
  ?path:string list ->
  ?output_format:request_output_format option ->
  unit ->
  request_list_children
(** [default_request_list_children ()] is the default value for type [request_list_children] *)

val default_request_run_op_mode : 
  ?path:string list ->
  ?output_format:request_output_format option ->
  unit ->
  request_run_op_mode
(** [default_request_run_op_mode ()] is the default value for type [request_run_op_mode] *)

val default_request_enter_configuration_mode : 
  ?exclusive:bool ->
  ?override_exclusive:bool ->
  unit ->
  request_enter_configuration_mode
(** [default_request_enter_configuration_mode ()] is the default value for type [request_enter_configuration_mode] *)

val default_request : unit -> request
(** [default_request ()] is the default value for type [request] *)

val default_request_envelope : 
  ?token:string option ->
  ?request:request ->
  unit ->
  request_envelope
(** [default_request_envelope ()] is the default value for type [request_envelope] *)

val default_status : unit -> status
(** [default_status ()] is the default value for type [status] *)

val default_response : 
  ?status:status ->
  ?output:string option ->
  ?error:string option ->
  ?warning:string option ->
  unit ->
  response
(** [default_response ()] is the default value for type [response] *)
