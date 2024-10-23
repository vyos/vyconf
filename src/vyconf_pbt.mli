
(** Code for vyconf.proto *)

(* generated from "data/vyconf.proto", do not edit *)



(** {2 Types} *)

type request_config_format =
  | Curly 
  | Json 

type request_output_format =
  | Out_plain 
  | Out_json 

type request_status = unit

type request_setup_session = {
  client_application : string option;
  on_behalf_of : int32 option;
}

type request_teardown = {
  on_behalf_of : int32 option;
}

type request_validate = {
  path : string list;
  output_format : request_output_format option;
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

type request_confirm = unit

type request_enter_configuration_mode = {
  exclusive : bool;
  override_exclusive : bool;
}

type request_exit_configuration_mode = unit

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
  | Validate of request_validate
  | Teardown of request_teardown

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


(** {2 Basic values} *)

val default_request_config_format : unit -> request_config_format
(** [default_request_config_format ()] is the default value for type [request_config_format] *)

val default_request_output_format : unit -> request_output_format
(** [default_request_output_format ()] is the default value for type [request_output_format] *)

val default_request_status : unit
(** [default_request_status ()] is the default value for type [request_status] *)

val default_request_setup_session : 
  ?client_application:string option ->
  ?on_behalf_of:int32 option ->
  unit ->
  request_setup_session
(** [default_request_setup_session ()] is the default value for type [request_setup_session] *)

val default_request_teardown : 
  ?on_behalf_of:int32 option ->
  unit ->
  request_teardown
(** [default_request_teardown ()] is the default value for type [request_teardown] *)

val default_request_validate : 
  ?path:string list ->
  ?output_format:request_output_format option ->
  unit ->
  request_validate
(** [default_request_validate ()] is the default value for type [request_validate] *)

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

val default_request_confirm : unit
(** [default_request_confirm ()] is the default value for type [request_confirm] *)

val default_request_enter_configuration_mode : 
  ?exclusive:bool ->
  ?override_exclusive:bool ->
  unit ->
  request_enter_configuration_mode
(** [default_request_enter_configuration_mode ()] is the default value for type [request_enter_configuration_mode] *)

val default_request_exit_configuration_mode : unit
(** [default_request_exit_configuration_mode ()] is the default value for type [request_exit_configuration_mode] *)

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


(** {2 Formatters} *)

val pp_request_config_format : Format.formatter -> request_config_format -> unit 
(** [pp_request_config_format v] formats v *)

val pp_request_output_format : Format.formatter -> request_output_format -> unit 
(** [pp_request_output_format v] formats v *)

val pp_request_status : Format.formatter -> request_status -> unit 
(** [pp_request_status v] formats v *)

val pp_request_setup_session : Format.formatter -> request_setup_session -> unit 
(** [pp_request_setup_session v] formats v *)

val pp_request_teardown : Format.formatter -> request_teardown -> unit 
(** [pp_request_teardown v] formats v *)

val pp_request_validate : Format.formatter -> request_validate -> unit 
(** [pp_request_validate v] formats v *)

val pp_request_set : Format.formatter -> request_set -> unit 
(** [pp_request_set v] formats v *)

val pp_request_delete : Format.formatter -> request_delete -> unit 
(** [pp_request_delete v] formats v *)

val pp_request_rename : Format.formatter -> request_rename -> unit 
(** [pp_request_rename v] formats v *)

val pp_request_copy : Format.formatter -> request_copy -> unit 
(** [pp_request_copy v] formats v *)

val pp_request_comment : Format.formatter -> request_comment -> unit 
(** [pp_request_comment v] formats v *)

val pp_request_commit : Format.formatter -> request_commit -> unit 
(** [pp_request_commit v] formats v *)

val pp_request_rollback : Format.formatter -> request_rollback -> unit 
(** [pp_request_rollback v] formats v *)

val pp_request_load : Format.formatter -> request_load -> unit 
(** [pp_request_load v] formats v *)

val pp_request_merge : Format.formatter -> request_merge -> unit 
(** [pp_request_merge v] formats v *)

val pp_request_save : Format.formatter -> request_save -> unit 
(** [pp_request_save v] formats v *)

val pp_request_show_config : Format.formatter -> request_show_config -> unit 
(** [pp_request_show_config v] formats v *)

val pp_request_exists : Format.formatter -> request_exists -> unit 
(** [pp_request_exists v] formats v *)

val pp_request_get_value : Format.formatter -> request_get_value -> unit 
(** [pp_request_get_value v] formats v *)

val pp_request_get_values : Format.formatter -> request_get_values -> unit 
(** [pp_request_get_values v] formats v *)

val pp_request_list_children : Format.formatter -> request_list_children -> unit 
(** [pp_request_list_children v] formats v *)

val pp_request_run_op_mode : Format.formatter -> request_run_op_mode -> unit 
(** [pp_request_run_op_mode v] formats v *)

val pp_request_confirm : Format.formatter -> request_confirm -> unit 
(** [pp_request_confirm v] formats v *)

val pp_request_enter_configuration_mode : Format.formatter -> request_enter_configuration_mode -> unit 
(** [pp_request_enter_configuration_mode v] formats v *)

val pp_request_exit_configuration_mode : Format.formatter -> request_exit_configuration_mode -> unit 
(** [pp_request_exit_configuration_mode v] formats v *)

val pp_request : Format.formatter -> request -> unit 
(** [pp_request v] formats v *)

val pp_request_envelope : Format.formatter -> request_envelope -> unit 
(** [pp_request_envelope v] formats v *)

val pp_status : Format.formatter -> status -> unit 
(** [pp_status v] formats v *)

val pp_response : Format.formatter -> response -> unit 
(** [pp_response v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_request_config_format : request_config_format -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_config_format v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_output_format : request_output_format -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_output_format v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_status : request_status -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_status v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_setup_session : request_setup_session -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_setup_session v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_teardown : request_teardown -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_teardown v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_validate : request_validate -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_validate v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_set : request_set -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_set v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_delete : request_delete -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_delete v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_rename : request_rename -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_rename v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_copy : request_copy -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_copy v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_comment : request_comment -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_comment v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_commit : request_commit -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_commit v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_rollback : request_rollback -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_rollback v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_load : request_load -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_load v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_merge : request_merge -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_merge v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_save : request_save -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_save v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_show_config : request_show_config -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_show_config v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_exists : request_exists -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_exists v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_get_value : request_get_value -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_get_value v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_get_values : request_get_values -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_get_values v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_list_children : request_list_children -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_list_children v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_run_op_mode : request_run_op_mode -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_run_op_mode v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_confirm : request_confirm -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_confirm v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_enter_configuration_mode : request_enter_configuration_mode -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_enter_configuration_mode v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_exit_configuration_mode : request_exit_configuration_mode -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_exit_configuration_mode v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request : request -> Pbrt.Encoder.t -> unit
(** [encode_pb_request v encoder] encodes [v] with the given [encoder] *)

val encode_pb_request_envelope : request_envelope -> Pbrt.Encoder.t -> unit
(** [encode_pb_request_envelope v encoder] encodes [v] with the given [encoder] *)

val encode_pb_status : status -> Pbrt.Encoder.t -> unit
(** [encode_pb_status v encoder] encodes [v] with the given [encoder] *)

val encode_pb_response : response -> Pbrt.Encoder.t -> unit
(** [encode_pb_response v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_request_config_format : Pbrt.Decoder.t -> request_config_format
(** [decode_pb_request_config_format decoder] decodes a [request_config_format] binary value from [decoder] *)

val decode_pb_request_output_format : Pbrt.Decoder.t -> request_output_format
(** [decode_pb_request_output_format decoder] decodes a [request_output_format] binary value from [decoder] *)

val decode_pb_request_status : Pbrt.Decoder.t -> request_status
(** [decode_pb_request_status decoder] decodes a [request_status] binary value from [decoder] *)

val decode_pb_request_setup_session : Pbrt.Decoder.t -> request_setup_session
(** [decode_pb_request_setup_session decoder] decodes a [request_setup_session] binary value from [decoder] *)

val decode_pb_request_teardown : Pbrt.Decoder.t -> request_teardown
(** [decode_pb_request_teardown decoder] decodes a [request_teardown] binary value from [decoder] *)

val decode_pb_request_validate : Pbrt.Decoder.t -> request_validate
(** [decode_pb_request_validate decoder] decodes a [request_validate] binary value from [decoder] *)

val decode_pb_request_set : Pbrt.Decoder.t -> request_set
(** [decode_pb_request_set decoder] decodes a [request_set] binary value from [decoder] *)

val decode_pb_request_delete : Pbrt.Decoder.t -> request_delete
(** [decode_pb_request_delete decoder] decodes a [request_delete] binary value from [decoder] *)

val decode_pb_request_rename : Pbrt.Decoder.t -> request_rename
(** [decode_pb_request_rename decoder] decodes a [request_rename] binary value from [decoder] *)

val decode_pb_request_copy : Pbrt.Decoder.t -> request_copy
(** [decode_pb_request_copy decoder] decodes a [request_copy] binary value from [decoder] *)

val decode_pb_request_comment : Pbrt.Decoder.t -> request_comment
(** [decode_pb_request_comment decoder] decodes a [request_comment] binary value from [decoder] *)

val decode_pb_request_commit : Pbrt.Decoder.t -> request_commit
(** [decode_pb_request_commit decoder] decodes a [request_commit] binary value from [decoder] *)

val decode_pb_request_rollback : Pbrt.Decoder.t -> request_rollback
(** [decode_pb_request_rollback decoder] decodes a [request_rollback] binary value from [decoder] *)

val decode_pb_request_load : Pbrt.Decoder.t -> request_load
(** [decode_pb_request_load decoder] decodes a [request_load] binary value from [decoder] *)

val decode_pb_request_merge : Pbrt.Decoder.t -> request_merge
(** [decode_pb_request_merge decoder] decodes a [request_merge] binary value from [decoder] *)

val decode_pb_request_save : Pbrt.Decoder.t -> request_save
(** [decode_pb_request_save decoder] decodes a [request_save] binary value from [decoder] *)

val decode_pb_request_show_config : Pbrt.Decoder.t -> request_show_config
(** [decode_pb_request_show_config decoder] decodes a [request_show_config] binary value from [decoder] *)

val decode_pb_request_exists : Pbrt.Decoder.t -> request_exists
(** [decode_pb_request_exists decoder] decodes a [request_exists] binary value from [decoder] *)

val decode_pb_request_get_value : Pbrt.Decoder.t -> request_get_value
(** [decode_pb_request_get_value decoder] decodes a [request_get_value] binary value from [decoder] *)

val decode_pb_request_get_values : Pbrt.Decoder.t -> request_get_values
(** [decode_pb_request_get_values decoder] decodes a [request_get_values] binary value from [decoder] *)

val decode_pb_request_list_children : Pbrt.Decoder.t -> request_list_children
(** [decode_pb_request_list_children decoder] decodes a [request_list_children] binary value from [decoder] *)

val decode_pb_request_run_op_mode : Pbrt.Decoder.t -> request_run_op_mode
(** [decode_pb_request_run_op_mode decoder] decodes a [request_run_op_mode] binary value from [decoder] *)

val decode_pb_request_confirm : Pbrt.Decoder.t -> request_confirm
(** [decode_pb_request_confirm decoder] decodes a [request_confirm] binary value from [decoder] *)

val decode_pb_request_enter_configuration_mode : Pbrt.Decoder.t -> request_enter_configuration_mode
(** [decode_pb_request_enter_configuration_mode decoder] decodes a [request_enter_configuration_mode] binary value from [decoder] *)

val decode_pb_request_exit_configuration_mode : Pbrt.Decoder.t -> request_exit_configuration_mode
(** [decode_pb_request_exit_configuration_mode decoder] decodes a [request_exit_configuration_mode] binary value from [decoder] *)

val decode_pb_request : Pbrt.Decoder.t -> request
(** [decode_pb_request decoder] decodes a [request] binary value from [decoder] *)

val decode_pb_request_envelope : Pbrt.Decoder.t -> request_envelope
(** [decode_pb_request_envelope decoder] decodes a [request_envelope] binary value from [decoder] *)

val decode_pb_status : Pbrt.Decoder.t -> status
(** [decode_pb_status decoder] decodes a [status] binary value from [decoder] *)

val decode_pb_response : Pbrt.Decoder.t -> response
(** [decode_pb_response decoder] decodes a [response] binary value from [decoder] *)
