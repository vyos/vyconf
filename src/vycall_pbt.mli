
(** Code for vycall.proto *)

(* generated from "data/vycall.proto", do not edit *)



(** {2 Types} *)

type status = {
  success : bool;
  out : string;
}

type call = {
  script_name : string;
  tag_value : string option;
  arg_value : string option;
  reply : status option;
}

type commit = {
  session_id : string;
  named_active : string option;
  named_proposed : string option;
  dry_run : bool;
  atomic : bool;
  background : bool;
  init : status option;
  calls : call list;
}


(** {2 Basic values} *)

val default_status : 
  ?success:bool ->
  ?out:string ->
  unit ->
  status
(** [default_status ()] is the default value for type [status] *)

val default_call : 
  ?script_name:string ->
  ?tag_value:string option ->
  ?arg_value:string option ->
  ?reply:status option ->
  unit ->
  call
(** [default_call ()] is the default value for type [call] *)

val default_commit : 
  ?session_id:string ->
  ?named_active:string option ->
  ?named_proposed:string option ->
  ?dry_run:bool ->
  ?atomic:bool ->
  ?background:bool ->
  ?init:status option ->
  ?calls:call list ->
  unit ->
  commit
(** [default_commit ()] is the default value for type [commit] *)


(** {2 Formatters} *)

val pp_status : Format.formatter -> status -> unit 
(** [pp_status v] formats v *)

val pp_call : Format.formatter -> call -> unit 
(** [pp_call v] formats v *)

val pp_commit : Format.formatter -> commit -> unit 
(** [pp_commit v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_status : status -> Pbrt.Encoder.t -> unit
(** [encode_pb_status v encoder] encodes [v] with the given [encoder] *)

val encode_pb_call : call -> Pbrt.Encoder.t -> unit
(** [encode_pb_call v encoder] encodes [v] with the given [encoder] *)

val encode_pb_commit : commit -> Pbrt.Encoder.t -> unit
(** [encode_pb_commit v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_status : Pbrt.Decoder.t -> status
(** [decode_pb_status decoder] decodes a [status] binary value from [decoder] *)

val decode_pb_call : Pbrt.Decoder.t -> call
(** [decode_pb_call decoder] decodes a [call] binary value from [decoder] *)

val decode_pb_commit : Pbrt.Decoder.t -> commit
(** [decode_pb_commit decoder] decodes a [commit] binary value from [decoder] *)
