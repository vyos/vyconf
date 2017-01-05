[@@@ocaml.warning "-27-30-39"]

type request_config_format =
  | Curly 
  | Json 

type request_setup_session = {
  client_application : string option;
  on_behalf_of : int32 option;
}

and request_setup_session_mutable = {
  mutable client_application : string option;
  mutable on_behalf_of : int32 option;
}

type request_set = {
  path : string list;
  value : string option;
  ephemeral : bool option;
}

and request_set_mutable = {
  mutable path : string list;
  mutable value : string option;
  mutable ephemeral : bool option;
}

type request_delete = {
  path : string list;
  value : string option;
}

and request_delete_mutable = {
  mutable path : string list;
  mutable value : string option;
}

type request_rename = {
  edit_level : string list;
  from : string;
  to_ : string;
}

and request_rename_mutable = {
  mutable edit_level : string list;
  mutable from : string;
  mutable to_ : string;
}

type request_copy = {
  edit_level : string list;
  from : string;
  to_ : string;
}

and request_copy_mutable = {
  mutable edit_level : string list;
  mutable from : string;
  mutable to_ : string;
}

type request_comment = {
  path : string list;
  comment : string;
}

and request_comment_mutable = {
  mutable path : string list;
  mutable comment : string;
}

type request_commit = {
  confirm : bool option;
  confirm_timeout : int32 option;
  comment : string option;
}

and request_commit_mutable = {
  mutable confirm : bool option;
  mutable confirm_timeout : int32 option;
  mutable comment : string option;
}

type request_rollback = {
  revision : int32;
}

and request_rollback_mutable = {
  mutable revision : int32;
}

type request_load = {
  location : string;
  format : request_config_format option;
}

and request_load_mutable = {
  mutable location : string;
  mutable format : request_config_format option;
}

type request_merge = {
  location : string;
  format : request_config_format option;
}

and request_merge_mutable = {
  mutable location : string;
  mutable format : request_config_format option;
}

type request_save = {
  location : string;
  format : request_config_format option;
}

and request_save_mutable = {
  mutable location : string;
  mutable format : request_config_format option;
}

type request_show_config = {
  path : string list;
  format : request_config_format option;
}

and request_show_config_mutable = {
  mutable path : string list;
  mutable format : request_config_format option;
}

type request_exists = {
  path : string list;
}

and request_exists_mutable = {
  mutable path : string list;
}

type request_get_value = {
  path : string list;
}

and request_get_value_mutable = {
  mutable path : string list;
}

type request_get_values = {
  path : string list;
}

and request_get_values_mutable = {
  mutable path : string list;
}

type request_list_children = {
  path : string list;
}

and request_list_children_mutable = {
  mutable path : string list;
}

type request_run_op_mode = {
  path : string list;
}

and request_run_op_mode_mutable = {
  mutable path : string list;
}

type request_enter_configuration_mode = {
  exclusive : bool option;
  override_exclusive : bool option;
}

and request_enter_configuration_mode_mutable = {
  mutable exclusive : bool option;
  mutable override_exclusive : bool option;
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

type status =
  | Success 
  | Fail 
  | Invalid_path 
  | Invalid_value 
  | Commit_in_progress 
  | Configuration_locked 
  | Internal_error 
  | Permission_denied 

type response = {
  status : status;
  output : string option;
  error : string option;
  warning : string option;
}

and response_mutable = {
  mutable status : status;
  mutable output : string option;
  mutable error : string option;
  mutable warning : string option;
}

let rec default_request_config_format () = (Curly:request_config_format)

let rec default_request_setup_session 
  ?client_application:((client_application:string option) = None)
  ?on_behalf_of:((on_behalf_of:int32 option) = None)
  () : request_setup_session  = {
  client_application;
  on_behalf_of;
}

and default_request_setup_session_mutable () : request_setup_session_mutable = {
  client_application = None;
  on_behalf_of = None;
}

let rec default_request_set 
  ?path:((path:string list) = [])
  ?value:((value:string option) = None)
  ?ephemeral:((ephemeral:bool option) = None)
  () : request_set  = {
  path;
  value;
  ephemeral;
}

and default_request_set_mutable () : request_set_mutable = {
  path = [];
  value = None;
  ephemeral = None;
}

let rec default_request_delete 
  ?path:((path:string list) = [])
  ?value:((value:string option) = None)
  () : request_delete  = {
  path;
  value;
}

and default_request_delete_mutable () : request_delete_mutable = {
  path = [];
  value = None;
}

let rec default_request_rename 
  ?edit_level:((edit_level:string list) = [])
  ?from:((from:string) = "")
  ?to_:((to_:string) = "")
  () : request_rename  = {
  edit_level;
  from;
  to_;
}

and default_request_rename_mutable () : request_rename_mutable = {
  edit_level = [];
  from = "";
  to_ = "";
}

let rec default_request_copy 
  ?edit_level:((edit_level:string list) = [])
  ?from:((from:string) = "")
  ?to_:((to_:string) = "")
  () : request_copy  = {
  edit_level;
  from;
  to_;
}

and default_request_copy_mutable () : request_copy_mutable = {
  edit_level = [];
  from = "";
  to_ = "";
}

let rec default_request_comment 
  ?path:((path:string list) = [])
  ?comment:((comment:string) = "")
  () : request_comment  = {
  path;
  comment;
}

and default_request_comment_mutable () : request_comment_mutable = {
  path = [];
  comment = "";
}

let rec default_request_commit 
  ?confirm:((confirm:bool option) = None)
  ?confirm_timeout:((confirm_timeout:int32 option) = None)
  ?comment:((comment:string option) = None)
  () : request_commit  = {
  confirm;
  confirm_timeout;
  comment;
}

and default_request_commit_mutable () : request_commit_mutable = {
  confirm = None;
  confirm_timeout = None;
  comment = None;
}

let rec default_request_rollback 
  ?revision:((revision:int32) = 0l)
  () : request_rollback  = {
  revision;
}

and default_request_rollback_mutable () : request_rollback_mutable = {
  revision = 0l;
}

let rec default_request_load 
  ?location:((location:string) = "")
  ?format:((format:request_config_format option) = None)
  () : request_load  = {
  location;
  format;
}

and default_request_load_mutable () : request_load_mutable = {
  location = "";
  format = None;
}

let rec default_request_merge 
  ?location:((location:string) = "")
  ?format:((format:request_config_format option) = None)
  () : request_merge  = {
  location;
  format;
}

and default_request_merge_mutable () : request_merge_mutable = {
  location = "";
  format = None;
}

let rec default_request_save 
  ?location:((location:string) = "")
  ?format:((format:request_config_format option) = None)
  () : request_save  = {
  location;
  format;
}

and default_request_save_mutable () : request_save_mutable = {
  location = "";
  format = None;
}

let rec default_request_show_config 
  ?path:((path:string list) = [])
  ?format:((format:request_config_format option) = None)
  () : request_show_config  = {
  path;
  format;
}

and default_request_show_config_mutable () : request_show_config_mutable = {
  path = [];
  format = None;
}

let rec default_request_exists 
  ?path:((path:string list) = [])
  () : request_exists  = {
  path;
}

and default_request_exists_mutable () : request_exists_mutable = {
  path = [];
}

let rec default_request_get_value 
  ?path:((path:string list) = [])
  () : request_get_value  = {
  path;
}

and default_request_get_value_mutable () : request_get_value_mutable = {
  path = [];
}

let rec default_request_get_values 
  ?path:((path:string list) = [])
  () : request_get_values  = {
  path;
}

and default_request_get_values_mutable () : request_get_values_mutable = {
  path = [];
}

let rec default_request_list_children 
  ?path:((path:string list) = [])
  () : request_list_children  = {
  path;
}

and default_request_list_children_mutable () : request_list_children_mutable = {
  path = [];
}

let rec default_request_run_op_mode 
  ?path:((path:string list) = [])
  () : request_run_op_mode  = {
  path;
}

and default_request_run_op_mode_mutable () : request_run_op_mode_mutable = {
  path = [];
}

let rec default_request_enter_configuration_mode 
  ?exclusive:((exclusive:bool option) = None)
  ?override_exclusive:((override_exclusive:bool option) = None)
  () : request_enter_configuration_mode  = {
  exclusive;
  override_exclusive;
}

and default_request_enter_configuration_mode_mutable () : request_enter_configuration_mode_mutable = {
  exclusive = None;
  override_exclusive = None;
}

let rec default_request (): request = Status

let rec default_status () = (Success:status)

let rec default_response 
  ?status:((status:status) = default_status ())
  ?output:((output:string option) = None)
  ?error:((error:string option) = None)
  ?warning:((warning:string option) = None)
  () : response  = {
  status;
  output;
  error;
  warning;
}

and default_response_mutable () : response_mutable = {
  status = default_status ();
  output = None;
  error = None;
  warning = None;
}

let rec decode_request_config_format d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Curly:request_config_format)
  | 1 -> (Json:request_config_format)
  | _ -> failwith "Unknown value for enum request_config_format"

let rec decode_request_setup_session d =
  let v = default_request_setup_session_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Bytes) -> (
      v.client_application <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_setup_session), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.on_behalf_of <- Some (Pbrt.Decoder.int32_as_varint d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_setup_session), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_setup_session = Obj.magic v in
  v

let rec decode_request_set d =
  let v = default_request_set_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_set), field(1)", pk))
    )
    | Some (2, Pbrt.Bytes) -> (
      v.value <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_set), field(2)", pk))
    )
    | Some (3, Pbrt.Varint) -> (
      v.ephemeral <- Some (Pbrt.Decoder.bool d);
      loop ()
    )
    | Some (3, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_set), field(3)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_set = Obj.magic v in
  v

let rec decode_request_delete d =
  let v = default_request_delete_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_delete), field(1)", pk))
    )
    | Some (2, Pbrt.Bytes) -> (
      v.value <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_delete), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_delete = Obj.magic v in
  v

let rec decode_request_rename d =
  let v = default_request_rename_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.edit_level <- List.rev v.edit_level;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.edit_level <- (Pbrt.Decoder.string d) :: v.edit_level;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_rename), field(1)", pk))
    )
    | Some (2, Pbrt.Bytes) -> (
      v.from <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_rename), field(2)", pk))
    )
    | Some (3, Pbrt.Bytes) -> (
      v.to_ <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (3, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_rename), field(3)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_rename = Obj.magic v in
  v

let rec decode_request_copy d =
  let v = default_request_copy_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.edit_level <- List.rev v.edit_level;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.edit_level <- (Pbrt.Decoder.string d) :: v.edit_level;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_copy), field(1)", pk))
    )
    | Some (2, Pbrt.Bytes) -> (
      v.from <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_copy), field(2)", pk))
    )
    | Some (3, Pbrt.Bytes) -> (
      v.to_ <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (3, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_copy), field(3)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_copy = Obj.magic v in
  v

let rec decode_request_comment d =
  let v = default_request_comment_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_comment), field(1)", pk))
    )
    | Some (2, Pbrt.Bytes) -> (
      v.comment <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_comment), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_comment = Obj.magic v in
  v

let rec decode_request_commit d =
  let v = default_request_commit_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Varint) -> (
      v.confirm <- Some (Pbrt.Decoder.bool d);
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_commit), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.confirm_timeout <- Some (Pbrt.Decoder.int32_as_varint d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_commit), field(2)", pk))
    )
    | Some (3, Pbrt.Bytes) -> (
      v.comment <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (3, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_commit), field(3)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_commit = Obj.magic v in
  v

let rec decode_request_rollback d =
  let v = default_request_rollback_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Varint) -> (
      v.revision <- Pbrt.Decoder.int32_as_varint d;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_rollback), field(1)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_rollback = Obj.magic v in
  v

let rec decode_request_load d =
  let v = default_request_load_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Bytes) -> (
      v.location <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_load), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.format <- Some (decode_request_config_format d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_load), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_load = Obj.magic v in
  v

let rec decode_request_merge d =
  let v = default_request_merge_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Bytes) -> (
      v.location <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_merge), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.format <- Some (decode_request_config_format d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_merge), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_merge = Obj.magic v in
  v

let rec decode_request_save d =
  let v = default_request_save_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Bytes) -> (
      v.location <- Pbrt.Decoder.string d;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_save), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.format <- Some (decode_request_config_format d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_save), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_save = Obj.magic v in
  v

let rec decode_request_show_config d =
  let v = default_request_show_config_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_show_config), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.format <- Some (decode_request_config_format d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_show_config), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_show_config = Obj.magic v in
  v

let rec decode_request_exists d =
  let v = default_request_exists_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_exists), field(1)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_exists = Obj.magic v in
  v

let rec decode_request_get_value d =
  let v = default_request_get_value_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_get_value), field(1)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_get_value = Obj.magic v in
  v

let rec decode_request_get_values d =
  let v = default_request_get_values_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_get_values), field(1)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_get_values = Obj.magic v in
  v

let rec decode_request_list_children d =
  let v = default_request_list_children_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_list_children), field(1)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_list_children = Obj.magic v in
  v

let rec decode_request_run_op_mode d =
  let v = default_request_run_op_mode_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    )
    | Some (1, Pbrt.Bytes) -> (
      v.path <- (Pbrt.Decoder.string d) :: v.path;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_run_op_mode), field(1)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_run_op_mode = Obj.magic v in
  v

let rec decode_request_enter_configuration_mode d =
  let v = default_request_enter_configuration_mode_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Varint) -> (
      v.exclusive <- Some (Pbrt.Decoder.bool d);
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_enter_configuration_mode), field(1)", pk))
    )
    | Some (2, Pbrt.Varint) -> (
      v.override_exclusive <- Some (Pbrt.Decoder.bool d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(request_enter_configuration_mode), field(2)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:request_enter_configuration_mode = Obj.magic v in
  v

let rec decode_request d = 
  let rec loop () = 
    let ret:request = match Pbrt.Decoder.key d with
      | None -> failwith "None of the known key is found"
      | Some (1, _) -> (Pbrt.Decoder.empty_nested d ; Status)
      | Some (2, _) -> Setup_session (decode_request_setup_session (Pbrt.Decoder.nested d))
      | Some (3, _) -> Set (decode_request_set (Pbrt.Decoder.nested d))
      | Some (4, _) -> Delete (decode_request_delete (Pbrt.Decoder.nested d))
      | Some (5, _) -> Rename (decode_request_rename (Pbrt.Decoder.nested d))
      | Some (6, _) -> Copy (decode_request_copy (Pbrt.Decoder.nested d))
      | Some (7, _) -> Comment (decode_request_comment (Pbrt.Decoder.nested d))
      | Some (8, _) -> Commit (decode_request_commit (Pbrt.Decoder.nested d))
      | Some (9, _) -> Rollback (decode_request_rollback (Pbrt.Decoder.nested d))
      | Some (10, _) -> Merge (decode_request_merge (Pbrt.Decoder.nested d))
      | Some (11, _) -> Save (decode_request_save (Pbrt.Decoder.nested d))
      | Some (12, _) -> Show_config (decode_request_show_config (Pbrt.Decoder.nested d))
      | Some (13, _) -> Exists (decode_request_exists (Pbrt.Decoder.nested d))
      | Some (14, _) -> Get_value (decode_request_get_value (Pbrt.Decoder.nested d))
      | Some (15, _) -> Get_values (decode_request_get_values (Pbrt.Decoder.nested d))
      | Some (16, _) -> List_children (decode_request_list_children (Pbrt.Decoder.nested d))
      | Some (17, _) -> Run_op_mode (decode_request_run_op_mode (Pbrt.Decoder.nested d))
      | Some (18, _) -> (Pbrt.Decoder.empty_nested d ; Confirm)
      | Some (19, _) -> Configure (decode_request_enter_configuration_mode (Pbrt.Decoder.nested d))
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

let rec decode_status d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Success:status)
  | 1 -> (Fail:status)
  | 2 -> (Invalid_path:status)
  | 3 -> (Invalid_value:status)
  | 4 -> (Commit_in_progress:status)
  | 5 -> (Configuration_locked:status)
  | 6 -> (Internal_error:status)
  | 7 -> (Permission_denied:status)
  | _ -> failwith "Unknown value for enum status"

let rec decode_response d =
  let v = default_response_mutable () in
  let rec loop () = 
    match Pbrt.Decoder.key d with
    | None -> (
    )
    | Some (1, Pbrt.Varint) -> (
      v.status <- decode_status d;
      loop ()
    )
    | Some (1, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(response), field(1)", pk))
    )
    | Some (2, Pbrt.Bytes) -> (
      v.output <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (2, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(response), field(2)", pk))
    )
    | Some (3, Pbrt.Bytes) -> (
      v.error <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (3, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(response), field(3)", pk))
    )
    | Some (4, Pbrt.Bytes) -> (
      v.warning <- Some (Pbrt.Decoder.string d);
      loop ()
    )
    | Some (4, pk) -> raise (
      Protobuf.Decoder.Failure (Protobuf.Decoder.Unexpected_payload ("Message(response), field(4)", pk))
    )
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind; loop ()
  in
  loop ();
  let v:response = Obj.magic v in
  v

let rec encode_request_config_format (v:request_config_format) encoder =
  match v with
  | Curly -> Pbrt.Encoder.int_as_varint (0) encoder
  | Json -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_request_setup_session (v:request_setup_session) encoder = 
  (
    match v.client_application with 
    | Some x -> (
      Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  (
    match v.on_behalf_of with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      Pbrt.Encoder.int32_as_varint x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_set (v:request_set) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  (
    match v.value with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  (
    match v.ephemeral with 
    | Some x -> (
      Pbrt.Encoder.key (3, Pbrt.Varint) encoder; 
      Pbrt.Encoder.bool x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_delete (v:request_delete) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  (
    match v.value with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_rename (v:request_rename) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.edit_level;
  Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.from encoder;
  Pbrt.Encoder.key (3, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.to_ encoder;
  ()

let rec encode_request_copy (v:request_copy) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.edit_level;
  Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.from encoder;
  Pbrt.Encoder.key (3, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.to_ encoder;
  ()

let rec encode_request_comment (v:request_comment) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.comment encoder;
  ()

let rec encode_request_commit (v:request_commit) encoder = 
  (
    match v.confirm with 
    | Some x -> (
      Pbrt.Encoder.key (1, Pbrt.Varint) encoder; 
      Pbrt.Encoder.bool x encoder;
    )
    | None -> ();
  );
  (
    match v.confirm_timeout with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      Pbrt.Encoder.int32_as_varint x encoder;
    )
    | None -> ();
  );
  (
    match v.comment with 
    | Some x -> (
      Pbrt.Encoder.key (3, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_rollback (v:request_rollback) encoder = 
  Pbrt.Encoder.key (1, Pbrt.Varint) encoder; 
  Pbrt.Encoder.int32_as_varint v.revision encoder;
  ()

let rec encode_request_load (v:request_load) encoder = 
  Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.location encoder;
  (
    match v.format with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      encode_request_config_format x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_merge (v:request_merge) encoder = 
  Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.location encoder;
  (
    match v.format with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      encode_request_config_format x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_save (v:request_save) encoder = 
  Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
  Pbrt.Encoder.string v.location encoder;
  (
    match v.format with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      encode_request_config_format x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_show_config (v:request_show_config) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  (
    match v.format with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      encode_request_config_format x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request_exists (v:request_exists) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  ()

let rec encode_request_get_value (v:request_get_value) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  ()

let rec encode_request_get_values (v:request_get_values) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  ()

let rec encode_request_list_children (v:request_list_children) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  ()

let rec encode_request_run_op_mode (v:request_run_op_mode) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.path;
  ()

let rec encode_request_enter_configuration_mode (v:request_enter_configuration_mode) encoder = 
  (
    match v.exclusive with 
    | Some x -> (
      Pbrt.Encoder.key (1, Pbrt.Varint) encoder; 
      Pbrt.Encoder.bool x encoder;
    )
    | None -> ();
  );
  (
    match v.override_exclusive with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Varint) encoder; 
      Pbrt.Encoder.bool x encoder;
    )
    | None -> ();
  );
  ()

let rec encode_request (v:request) encoder = 
  match v with
  | Status -> (
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.empty_nested encoder
  )
  | Setup_session x -> (
    Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_setup_session x) encoder;
  )
  | Set x -> (
    Pbrt.Encoder.key (3, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_set x) encoder;
  )
  | Delete x -> (
    Pbrt.Encoder.key (4, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_delete x) encoder;
  )
  | Rename x -> (
    Pbrt.Encoder.key (5, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_rename x) encoder;
  )
  | Copy x -> (
    Pbrt.Encoder.key (6, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_copy x) encoder;
  )
  | Comment x -> (
    Pbrt.Encoder.key (7, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_comment x) encoder;
  )
  | Commit x -> (
    Pbrt.Encoder.key (8, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_commit x) encoder;
  )
  | Rollback x -> (
    Pbrt.Encoder.key (9, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_rollback x) encoder;
  )
  | Merge x -> (
    Pbrt.Encoder.key (10, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_merge x) encoder;
  )
  | Save x -> (
    Pbrt.Encoder.key (11, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_save x) encoder;
  )
  | Show_config x -> (
    Pbrt.Encoder.key (12, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_show_config x) encoder;
  )
  | Exists x -> (
    Pbrt.Encoder.key (13, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_exists x) encoder;
  )
  | Get_value x -> (
    Pbrt.Encoder.key (14, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_get_value x) encoder;
  )
  | Get_values x -> (
    Pbrt.Encoder.key (15, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_get_values x) encoder;
  )
  | List_children x -> (
    Pbrt.Encoder.key (16, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_list_children x) encoder;
  )
  | Run_op_mode x -> (
    Pbrt.Encoder.key (17, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_run_op_mode x) encoder;
  )
  | Confirm -> (
    Pbrt.Encoder.key (18, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.empty_nested encoder
  )
  | Configure x -> (
    Pbrt.Encoder.key (19, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_request_enter_configuration_mode x) encoder;
  )

let rec encode_status (v:status) encoder =
  match v with
  | Success -> Pbrt.Encoder.int_as_varint (0) encoder
  | Fail -> Pbrt.Encoder.int_as_varint 1 encoder
  | Invalid_path -> Pbrt.Encoder.int_as_varint 2 encoder
  | Invalid_value -> Pbrt.Encoder.int_as_varint 3 encoder
  | Commit_in_progress -> Pbrt.Encoder.int_as_varint 4 encoder
  | Configuration_locked -> Pbrt.Encoder.int_as_varint 5 encoder
  | Internal_error -> Pbrt.Encoder.int_as_varint 6 encoder
  | Permission_denied -> Pbrt.Encoder.int_as_varint 7 encoder

let rec encode_response (v:response) encoder = 
  Pbrt.Encoder.key (1, Pbrt.Varint) encoder; 
  encode_status v.status encoder;
  (
    match v.output with 
    | Some x -> (
      Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  (
    match v.error with 
    | Some x -> (
      Pbrt.Encoder.key (3, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  (
    match v.warning with 
    | Some x -> (
      Pbrt.Encoder.key (4, Pbrt.Bytes) encoder; 
      Pbrt.Encoder.string x encoder;
    )
    | None -> ();
  );
  ()

let rec pp_request_config_format fmt (v:request_config_format) =
  match v with
  | Curly -> Format.fprintf fmt "Curly"
  | Json -> Format.fprintf fmt "Json"

let rec pp_request_setup_session fmt (v:request_setup_session) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "client_application" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.client_application;
    Pbrt.Pp.pp_record_field "on_behalf_of" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.on_behalf_of;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_set fmt (v:request_set) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field "value" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.value;
    Pbrt.Pp.pp_record_field "ephemeral" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.ephemeral;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_delete fmt (v:request_delete) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field "value" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.value;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_rename fmt (v:request_rename) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "edit_level" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.edit_level;
    Pbrt.Pp.pp_record_field "from" Pbrt.Pp.pp_string fmt v.from;
    Pbrt.Pp.pp_record_field "to_" Pbrt.Pp.pp_string fmt v.to_;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_copy fmt (v:request_copy) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "edit_level" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.edit_level;
    Pbrt.Pp.pp_record_field "from" Pbrt.Pp.pp_string fmt v.from;
    Pbrt.Pp.pp_record_field "to_" Pbrt.Pp.pp_string fmt v.to_;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_comment fmt (v:request_comment) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field "comment" Pbrt.Pp.pp_string fmt v.comment;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_commit fmt (v:request_commit) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "confirm" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.confirm;
    Pbrt.Pp.pp_record_field "confirm_timeout" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.confirm_timeout;
    Pbrt.Pp.pp_record_field "comment" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.comment;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_rollback fmt (v:request_rollback) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "revision" Pbrt.Pp.pp_int32 fmt v.revision;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_load fmt (v:request_load) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "location" Pbrt.Pp.pp_string fmt v.location;
    Pbrt.Pp.pp_record_field "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_merge fmt (v:request_merge) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "location" Pbrt.Pp.pp_string fmt v.location;
    Pbrt.Pp.pp_record_field "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_save fmt (v:request_save) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "location" Pbrt.Pp.pp_string fmt v.location;
    Pbrt.Pp.pp_record_field "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_show_config fmt (v:request_show_config) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_exists fmt (v:request_exists) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_get_value fmt (v:request_get_value) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_get_values fmt (v:request_get_values) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_list_children fmt (v:request_list_children) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_run_op_mode fmt (v:request_run_op_mode) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_enter_configuration_mode fmt (v:request_enter_configuration_mode) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "exclusive" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.exclusive;
    Pbrt.Pp.pp_record_field "override_exclusive" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.override_exclusive;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request fmt (v:request) =
  match v with
  | Status  -> Format.fprintf fmt "Status"
  | Setup_session x -> Format.fprintf fmt "@[Setup_session(%a)@]" pp_request_setup_session x
  | Set x -> Format.fprintf fmt "@[Set(%a)@]" pp_request_set x
  | Delete x -> Format.fprintf fmt "@[Delete(%a)@]" pp_request_delete x
  | Rename x -> Format.fprintf fmt "@[Rename(%a)@]" pp_request_rename x
  | Copy x -> Format.fprintf fmt "@[Copy(%a)@]" pp_request_copy x
  | Comment x -> Format.fprintf fmt "@[Comment(%a)@]" pp_request_comment x
  | Commit x -> Format.fprintf fmt "@[Commit(%a)@]" pp_request_commit x
  | Rollback x -> Format.fprintf fmt "@[Rollback(%a)@]" pp_request_rollback x
  | Merge x -> Format.fprintf fmt "@[Merge(%a)@]" pp_request_merge x
  | Save x -> Format.fprintf fmt "@[Save(%a)@]" pp_request_save x
  | Show_config x -> Format.fprintf fmt "@[Show_config(%a)@]" pp_request_show_config x
  | Exists x -> Format.fprintf fmt "@[Exists(%a)@]" pp_request_exists x
  | Get_value x -> Format.fprintf fmt "@[Get_value(%a)@]" pp_request_get_value x
  | Get_values x -> Format.fprintf fmt "@[Get_values(%a)@]" pp_request_get_values x
  | List_children x -> Format.fprintf fmt "@[List_children(%a)@]" pp_request_list_children x
  | Run_op_mode x -> Format.fprintf fmt "@[Run_op_mode(%a)@]" pp_request_run_op_mode x
  | Confirm  -> Format.fprintf fmt "Confirm"
  | Configure x -> Format.fprintf fmt "@[Configure(%a)@]" pp_request_enter_configuration_mode x

let rec pp_status fmt (v:status) =
  match v with
  | Success -> Format.fprintf fmt "Success"
  | Fail -> Format.fprintf fmt "Fail"
  | Invalid_path -> Format.fprintf fmt "Invalid_path"
  | Invalid_value -> Format.fprintf fmt "Invalid_value"
  | Commit_in_progress -> Format.fprintf fmt "Commit_in_progress"
  | Configuration_locked -> Format.fprintf fmt "Configuration_locked"
  | Internal_error -> Format.fprintf fmt "Internal_error"
  | Permission_denied -> Format.fprintf fmt "Permission_denied"

let rec pp_response fmt (v:response) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "status" pp_status fmt v.status;
    Pbrt.Pp.pp_record_field "output" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.output;
    Pbrt.Pp.pp_record_field "error" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.error;
    Pbrt.Pp.pp_record_field "warning" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.warning;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()
