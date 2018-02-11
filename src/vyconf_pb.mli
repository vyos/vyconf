(** vyconf.proto Binary Encoding *)


(** {2 Protobuf Encoding} *)

val encode_request_config_format : Vyconf_types.request_config_format -> Pbrt.Encoder.t -> unit
(** [encode_request_config_format v encoder] encodes [v] with the given [encoder] *)

val encode_request_output_format : Vyconf_types.request_output_format -> Pbrt.Encoder.t -> unit
(** [encode_request_output_format v encoder] encodes [v] with the given [encoder] *)

val encode_request_setup_session : Vyconf_types.request_setup_session -> Pbrt.Encoder.t -> unit
(** [encode_request_setup_session v encoder] encodes [v] with the given [encoder] *)

val encode_request_set : Vyconf_types.request_set -> Pbrt.Encoder.t -> unit
(** [encode_request_set v encoder] encodes [v] with the given [encoder] *)

val encode_request_delete : Vyconf_types.request_delete -> Pbrt.Encoder.t -> unit
(** [encode_request_delete v encoder] encodes [v] with the given [encoder] *)

val encode_request_rename : Vyconf_types.request_rename -> Pbrt.Encoder.t -> unit
(** [encode_request_rename v encoder] encodes [v] with the given [encoder] *)

val encode_request_copy : Vyconf_types.request_copy -> Pbrt.Encoder.t -> unit
(** [encode_request_copy v encoder] encodes [v] with the given [encoder] *)

val encode_request_comment : Vyconf_types.request_comment -> Pbrt.Encoder.t -> unit
(** [encode_request_comment v encoder] encodes [v] with the given [encoder] *)

val encode_request_commit : Vyconf_types.request_commit -> Pbrt.Encoder.t -> unit
(** [encode_request_commit v encoder] encodes [v] with the given [encoder] *)

val encode_request_rollback : Vyconf_types.request_rollback -> Pbrt.Encoder.t -> unit
(** [encode_request_rollback v encoder] encodes [v] with the given [encoder] *)

val encode_request_load : Vyconf_types.request_load -> Pbrt.Encoder.t -> unit
(** [encode_request_load v encoder] encodes [v] with the given [encoder] *)

val encode_request_merge : Vyconf_types.request_merge -> Pbrt.Encoder.t -> unit
(** [encode_request_merge v encoder] encodes [v] with the given [encoder] *)

val encode_request_save : Vyconf_types.request_save -> Pbrt.Encoder.t -> unit
(** [encode_request_save v encoder] encodes [v] with the given [encoder] *)

val encode_request_show_config : Vyconf_types.request_show_config -> Pbrt.Encoder.t -> unit
(** [encode_request_show_config v encoder] encodes [v] with the given [encoder] *)

val encode_request_exists : Vyconf_types.request_exists -> Pbrt.Encoder.t -> unit
(** [encode_request_exists v encoder] encodes [v] with the given [encoder] *)

val encode_request_get_value : Vyconf_types.request_get_value -> Pbrt.Encoder.t -> unit
(** [encode_request_get_value v encoder] encodes [v] with the given [encoder] *)

val encode_request_get_values : Vyconf_types.request_get_values -> Pbrt.Encoder.t -> unit
(** [encode_request_get_values v encoder] encodes [v] with the given [encoder] *)

val encode_request_list_children : Vyconf_types.request_list_children -> Pbrt.Encoder.t -> unit
(** [encode_request_list_children v encoder] encodes [v] with the given [encoder] *)

val encode_request_run_op_mode : Vyconf_types.request_run_op_mode -> Pbrt.Encoder.t -> unit
(** [encode_request_run_op_mode v encoder] encodes [v] with the given [encoder] *)

val encode_request_enter_configuration_mode : Vyconf_types.request_enter_configuration_mode -> Pbrt.Encoder.t -> unit
(** [encode_request_enter_configuration_mode v encoder] encodes [v] with the given [encoder] *)

val encode_request : Vyconf_types.request -> Pbrt.Encoder.t -> unit
(** [encode_request v encoder] encodes [v] with the given [encoder] *)

val encode_request_envelope : Vyconf_types.request_envelope -> Pbrt.Encoder.t -> unit
(** [encode_request_envelope v encoder] encodes [v] with the given [encoder] *)

val encode_status : Vyconf_types.status -> Pbrt.Encoder.t -> unit
(** [encode_status v encoder] encodes [v] with the given [encoder] *)

val encode_response : Vyconf_types.response -> Pbrt.Encoder.t -> unit
(** [encode_response v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_request_config_format : Pbrt.Decoder.t -> Vyconf_types.request_config_format
(** [decode_request_config_format decoder] decodes a [request_config_format] value from [decoder] *)

val decode_request_output_format : Pbrt.Decoder.t -> Vyconf_types.request_output_format
(** [decode_request_output_format decoder] decodes a [request_output_format] value from [decoder] *)

val decode_request_setup_session : Pbrt.Decoder.t -> Vyconf_types.request_setup_session
(** [decode_request_setup_session decoder] decodes a [request_setup_session] value from [decoder] *)

val decode_request_set : Pbrt.Decoder.t -> Vyconf_types.request_set
(** [decode_request_set decoder] decodes a [request_set] value from [decoder] *)

val decode_request_delete : Pbrt.Decoder.t -> Vyconf_types.request_delete
(** [decode_request_delete decoder] decodes a [request_delete] value from [decoder] *)

val decode_request_rename : Pbrt.Decoder.t -> Vyconf_types.request_rename
(** [decode_request_rename decoder] decodes a [request_rename] value from [decoder] *)

val decode_request_copy : Pbrt.Decoder.t -> Vyconf_types.request_copy
(** [decode_request_copy decoder] decodes a [request_copy] value from [decoder] *)

val decode_request_comment : Pbrt.Decoder.t -> Vyconf_types.request_comment
(** [decode_request_comment decoder] decodes a [request_comment] value from [decoder] *)

val decode_request_commit : Pbrt.Decoder.t -> Vyconf_types.request_commit
(** [decode_request_commit decoder] decodes a [request_commit] value from [decoder] *)

val decode_request_rollback : Pbrt.Decoder.t -> Vyconf_types.request_rollback
(** [decode_request_rollback decoder] decodes a [request_rollback] value from [decoder] *)

val decode_request_load : Pbrt.Decoder.t -> Vyconf_types.request_load
(** [decode_request_load decoder] decodes a [request_load] value from [decoder] *)

val decode_request_merge : Pbrt.Decoder.t -> Vyconf_types.request_merge
(** [decode_request_merge decoder] decodes a [request_merge] value from [decoder] *)

val decode_request_save : Pbrt.Decoder.t -> Vyconf_types.request_save
(** [decode_request_save decoder] decodes a [request_save] value from [decoder] *)

val decode_request_show_config : Pbrt.Decoder.t -> Vyconf_types.request_show_config
(** [decode_request_show_config decoder] decodes a [request_show_config] value from [decoder] *)

val decode_request_exists : Pbrt.Decoder.t -> Vyconf_types.request_exists
(** [decode_request_exists decoder] decodes a [request_exists] value from [decoder] *)

val decode_request_get_value : Pbrt.Decoder.t -> Vyconf_types.request_get_value
(** [decode_request_get_value decoder] decodes a [request_get_value] value from [decoder] *)

val decode_request_get_values : Pbrt.Decoder.t -> Vyconf_types.request_get_values
(** [decode_request_get_values decoder] decodes a [request_get_values] value from [decoder] *)

val decode_request_list_children : Pbrt.Decoder.t -> Vyconf_types.request_list_children
(** [decode_request_list_children decoder] decodes a [request_list_children] value from [decoder] *)

val decode_request_run_op_mode : Pbrt.Decoder.t -> Vyconf_types.request_run_op_mode
(** [decode_request_run_op_mode decoder] decodes a [request_run_op_mode] value from [decoder] *)

val decode_request_enter_configuration_mode : Pbrt.Decoder.t -> Vyconf_types.request_enter_configuration_mode
(** [decode_request_enter_configuration_mode decoder] decodes a [request_enter_configuration_mode] value from [decoder] *)

val decode_request : Pbrt.Decoder.t -> Vyconf_types.request
(** [decode_request decoder] decodes a [request] value from [decoder] *)

val decode_request_envelope : Pbrt.Decoder.t -> Vyconf_types.request_envelope
(** [decode_request_envelope decoder] decodes a [request_envelope] value from [decoder] *)

val decode_status : Pbrt.Decoder.t -> Vyconf_types.status
(** [decode_status decoder] decodes a [status] value from [decoder] *)

val decode_response : Pbrt.Decoder.t -> Vyconf_types.response
(** [decode_response decoder] decodes a [response] value from [decoder] *)
