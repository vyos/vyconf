[@@@ocaml.warning "-27-30-39"]

type request_setup_session_mutable = {
  mutable client_application : string option;
  mutable on_behalf_of : int32 option;
}

let default_request_setup_session_mutable () : request_setup_session_mutable = {
  client_application = None;
  on_behalf_of = None;
}

type request_set_mutable = {
  mutable path : string list;
  mutable ephemeral : bool option;
}

let default_request_set_mutable () : request_set_mutable = {
  path = [];
  ephemeral = None;
}

type request_delete_mutable = {
  mutable path : string list;
}

let default_request_delete_mutable () : request_delete_mutable = {
  path = [];
}

type request_rename_mutable = {
  mutable edit_level : string list;
  mutable from : string;
  mutable to_ : string;
}

let default_request_rename_mutable () : request_rename_mutable = {
  edit_level = [];
  from = "";
  to_ = "";
}

type request_copy_mutable = {
  mutable edit_level : string list;
  mutable from : string;
  mutable to_ : string;
}

let default_request_copy_mutable () : request_copy_mutable = {
  edit_level = [];
  from = "";
  to_ = "";
}

type request_comment_mutable = {
  mutable path : string list;
  mutable comment : string;
}

let default_request_comment_mutable () : request_comment_mutable = {
  path = [];
  comment = "";
}

type request_commit_mutable = {
  mutable confirm : bool option;
  mutable confirm_timeout : int32 option;
  mutable comment : string option;
}

let default_request_commit_mutable () : request_commit_mutable = {
  confirm = None;
  confirm_timeout = None;
  comment = None;
}

type request_rollback_mutable = {
  mutable revision : int32;
}

let default_request_rollback_mutable () : request_rollback_mutable = {
  revision = 0l;
}

type request_load_mutable = {
  mutable location : string;
  mutable format : Vyconf_types.request_config_format option;
}

let default_request_load_mutable () : request_load_mutable = {
  location = "";
  format = None;
}

type request_merge_mutable = {
  mutable location : string;
  mutable format : Vyconf_types.request_config_format option;
}

let default_request_merge_mutable () : request_merge_mutable = {
  location = "";
  format = None;
}

type request_save_mutable = {
  mutable location : string;
  mutable format : Vyconf_types.request_config_format option;
}

let default_request_save_mutable () : request_save_mutable = {
  location = "";
  format = None;
}

type request_show_config_mutable = {
  mutable path : string list;
  mutable format : Vyconf_types.request_config_format option;
}

let default_request_show_config_mutable () : request_show_config_mutable = {
  path = [];
  format = None;
}

type request_exists_mutable = {
  mutable path : string list;
}

let default_request_exists_mutable () : request_exists_mutable = {
  path = [];
}

type request_get_value_mutable = {
  mutable path : string list;
  mutable output_format : Vyconf_types.request_output_format option;
}

let default_request_get_value_mutable () : request_get_value_mutable = {
  path = [];
  output_format = None;
}

type request_get_values_mutable = {
  mutable path : string list;
  mutable output_format : Vyconf_types.request_output_format option;
}

let default_request_get_values_mutable () : request_get_values_mutable = {
  path = [];
  output_format = None;
}

type request_list_children_mutable = {
  mutable path : string list;
  mutable output_format : Vyconf_types.request_output_format option;
}

let default_request_list_children_mutable () : request_list_children_mutable = {
  path = [];
  output_format = None;
}

type request_run_op_mode_mutable = {
  mutable path : string list;
  mutable output_format : Vyconf_types.request_output_format option;
}

let default_request_run_op_mode_mutable () : request_run_op_mode_mutable = {
  path = [];
  output_format = None;
}

type request_enter_configuration_mode_mutable = {
  mutable exclusive : bool;
  mutable override_exclusive : bool;
}

let default_request_enter_configuration_mode_mutable () : request_enter_configuration_mode_mutable = {
  exclusive = false;
  override_exclusive = false;
}

type request_envelope_mutable = {
  mutable token : string option;
  mutable request : Vyconf_types.request;
}

let default_request_envelope_mutable () : request_envelope_mutable = {
  token = None;
  request = Vyconf_types.default_request ();
}

type response_mutable = {
  mutable status : Vyconf_types.status;
  mutable output : string option;
  mutable error : string option;
  mutable warning : string option;
}

let default_response_mutable () : response_mutable = {
  status = Vyconf_types.default_status ();
  output = None;
  error = None;
  warning = None;
}


let rec decode_request_config_format d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Vyconf_types.Curly:Vyconf_types.request_config_format)
  | 1 -> (Vyconf_types.Json:Vyconf_types.request_config_format)
  | _ -> Pbrt.Decoder.malformed_variant "request_config_format"

let rec decode_request_output_format d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Vyconf_types.Out_plain:Vyconf_types.request_output_format)
  | 1 -> (Vyconf_types.Out_json:Vyconf_types.request_output_format)
  | _ -> Pbrt.Decoder.malformed_variant "request_output_format"

let rec decode_request_setup_session d =
  let v = default_request_setup_session_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.client_application <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_setup_session), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.on_behalf_of <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_setup_session), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.client_application = v.client_application;
    Vyconf_types.on_behalf_of = v.on_behalf_of;
  } : Vyconf_types.request_setup_session)

let rec decode_request_set d =
  let v = default_request_set_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_set), field(1)" pk
    | Some (3, Pbrt.Varint) -> begin
      v.ephemeral <- Some (Pbrt.Decoder.bool d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_set), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.ephemeral = v.ephemeral;
  } : Vyconf_types.request_set)

let rec decode_request_delete d =
  let v = default_request_delete_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_delete), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
  } : Vyconf_types.request_delete)

let rec decode_request_rename d =
  let v = default_request_rename_mutable () in
  let continue__= ref true in
  let to__is_set = ref false in
  let from_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.edit_level <- List.rev v.edit_level;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.edit_level <- (Pbrt.Decoder.string d) :: v.edit_level;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_rename), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.from <- Pbrt.Decoder.string d; from_is_set := true;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_rename), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.to_ <- Pbrt.Decoder.string d; to__is_set := true;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_rename), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !to__is_set then Pbrt.Decoder.missing_field "to_" end;
  begin if not !from_is_set then Pbrt.Decoder.missing_field "from" end;
  ({
    Vyconf_types.edit_level = v.edit_level;
    Vyconf_types.from = v.from;
    Vyconf_types.to_ = v.to_;
  } : Vyconf_types.request_rename)

let rec decode_request_copy d =
  let v = default_request_copy_mutable () in
  let continue__= ref true in
  let to__is_set = ref false in
  let from_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.edit_level <- List.rev v.edit_level;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.edit_level <- (Pbrt.Decoder.string d) :: v.edit_level;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_copy), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.from <- Pbrt.Decoder.string d; from_is_set := true;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_copy), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.to_ <- Pbrt.Decoder.string d; to__is_set := true;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_copy), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !to__is_set then Pbrt.Decoder.missing_field "to_" end;
  begin if not !from_is_set then Pbrt.Decoder.missing_field "from" end;
  ({
    Vyconf_types.edit_level = v.edit_level;
    Vyconf_types.from = v.from;
    Vyconf_types.to_ = v.to_;
  } : Vyconf_types.request_copy)

let rec decode_request_comment d =
  let v = default_request_comment_mutable () in
  let continue__= ref true in
  let comment_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_comment), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.comment <- Pbrt.Decoder.string d; comment_is_set := true;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_comment), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !comment_is_set then Pbrt.Decoder.missing_field "comment" end;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.comment = v.comment;
  } : Vyconf_types.request_comment)

let rec decode_request_commit d =
  let v = default_request_commit_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.confirm <- Some (Pbrt.Decoder.bool d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_commit), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.confirm_timeout <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_commit), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.comment <- Some (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_commit), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.confirm = v.confirm;
    Vyconf_types.confirm_timeout = v.confirm_timeout;
    Vyconf_types.comment = v.comment;
  } : Vyconf_types.request_commit)

let rec decode_request_rollback d =
  let v = default_request_rollback_mutable () in
  let continue__= ref true in
  let revision_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.revision <- Pbrt.Decoder.int32_as_varint d; revision_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_rollback), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !revision_is_set then Pbrt.Decoder.missing_field "revision" end;
  ({
    Vyconf_types.revision = v.revision;
  } : Vyconf_types.request_rollback)

let rec decode_request_load d =
  let v = default_request_load_mutable () in
  let continue__= ref true in
  let location_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.location <- Pbrt.Decoder.string d; location_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_load), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.format <- Some (decode_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_load), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !location_is_set then Pbrt.Decoder.missing_field "location" end;
  ({
    Vyconf_types.location = v.location;
    Vyconf_types.format = v.format;
  } : Vyconf_types.request_load)

let rec decode_request_merge d =
  let v = default_request_merge_mutable () in
  let continue__= ref true in
  let location_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.location <- Pbrt.Decoder.string d; location_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_merge), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.format <- Some (decode_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_merge), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !location_is_set then Pbrt.Decoder.missing_field "location" end;
  ({
    Vyconf_types.location = v.location;
    Vyconf_types.format = v.format;
  } : Vyconf_types.request_merge)

let rec decode_request_save d =
  let v = default_request_save_mutable () in
  let continue__= ref true in
  let location_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.location <- Pbrt.Decoder.string d; location_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_save), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.format <- Some (decode_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_save), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !location_is_set then Pbrt.Decoder.missing_field "location" end;
  ({
    Vyconf_types.location = v.location;
    Vyconf_types.format = v.format;
  } : Vyconf_types.request_save)

let rec decode_request_show_config d =
  let v = default_request_show_config_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_show_config), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.format <- Some (decode_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_show_config), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.format = v.format;
  } : Vyconf_types.request_show_config)

let rec decode_request_exists d =
  let v = default_request_exists_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_exists), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
  } : Vyconf_types.request_exists)

let rec decode_request_get_value d =
  let v = default_request_get_value_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_get_value), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.output_format <- Some (decode_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_get_value), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.output_format = v.output_format;
  } : Vyconf_types.request_get_value)

let rec decode_request_get_values d =
  let v = default_request_get_values_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_get_values), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.output_format <- Some (decode_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_get_values), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.output_format = v.output_format;
  } : Vyconf_types.request_get_values)

let rec decode_request_list_children d =
  let v = default_request_list_children_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_list_children), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.output_format <- Some (decode_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_list_children), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.output_format = v.output_format;
  } : Vyconf_types.request_list_children)

let rec decode_request_run_op_mode d =
  let v = default_request_run_op_mode_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.path <- List.rev v.path;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.path <- (Pbrt.Decoder.string d) :: v.path;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_run_op_mode), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.output_format <- Some (decode_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_run_op_mode), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Vyconf_types.path = v.path;
    Vyconf_types.output_format = v.output_format;
  } : Vyconf_types.request_run_op_mode)

let rec decode_request_enter_configuration_mode d =
  let v = default_request_enter_configuration_mode_mutable () in
  let continue__= ref true in
  let override_exclusive_is_set = ref false in
  let exclusive_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.exclusive <- Pbrt.Decoder.bool d; exclusive_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_enter_configuration_mode), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.override_exclusive <- Pbrt.Decoder.bool d; override_exclusive_is_set := true;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_enter_configuration_mode), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !override_exclusive_is_set then Pbrt.Decoder.missing_field "override_exclusive" end;
  begin if not !exclusive_is_set then Pbrt.Decoder.missing_field "exclusive" end;
  ({
    Vyconf_types.exclusive = v.exclusive;
    Vyconf_types.override_exclusive = v.override_exclusive;
  } : Vyconf_types.request_enter_configuration_mode)

let rec decode_request d = 
  let rec loop () = 
    let ret:Vyconf_types.request = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "request"
      | Some (1, _) -> (Pbrt.Decoder.empty_nested d ; Vyconf_types.Status)
      | Some (2, _) -> Vyconf_types.Setup_session (decode_request_setup_session (Pbrt.Decoder.nested d))
      | Some (3, _) -> Vyconf_types.Set (decode_request_set (Pbrt.Decoder.nested d))
      | Some (4, _) -> Vyconf_types.Delete (decode_request_delete (Pbrt.Decoder.nested d))
      | Some (5, _) -> Vyconf_types.Rename (decode_request_rename (Pbrt.Decoder.nested d))
      | Some (6, _) -> Vyconf_types.Copy (decode_request_copy (Pbrt.Decoder.nested d))
      | Some (7, _) -> Vyconf_types.Comment (decode_request_comment (Pbrt.Decoder.nested d))
      | Some (8, _) -> Vyconf_types.Commit (decode_request_commit (Pbrt.Decoder.nested d))
      | Some (9, _) -> Vyconf_types.Rollback (decode_request_rollback (Pbrt.Decoder.nested d))
      | Some (10, _) -> Vyconf_types.Merge (decode_request_merge (Pbrt.Decoder.nested d))
      | Some (11, _) -> Vyconf_types.Save (decode_request_save (Pbrt.Decoder.nested d))
      | Some (12, _) -> Vyconf_types.Show_config (decode_request_show_config (Pbrt.Decoder.nested d))
      | Some (13, _) -> Vyconf_types.Exists (decode_request_exists (Pbrt.Decoder.nested d))
      | Some (14, _) -> Vyconf_types.Get_value (decode_request_get_value (Pbrt.Decoder.nested d))
      | Some (15, _) -> Vyconf_types.Get_values (decode_request_get_values (Pbrt.Decoder.nested d))
      | Some (16, _) -> Vyconf_types.List_children (decode_request_list_children (Pbrt.Decoder.nested d))
      | Some (17, _) -> Vyconf_types.Run_op_mode (decode_request_run_op_mode (Pbrt.Decoder.nested d))
      | Some (18, _) -> (Pbrt.Decoder.empty_nested d ; Vyconf_types.Confirm)
      | Some (19, _) -> Vyconf_types.Configure (decode_request_enter_configuration_mode (Pbrt.Decoder.nested d))
      | Some (20, _) -> (Pbrt.Decoder.empty_nested d ; Vyconf_types.Exit_configure)
      | Some (21, _) -> Vyconf_types.Teardown (Pbrt.Decoder.string d)
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

let rec decode_request_envelope d =
  let v = default_request_envelope_mutable () in
  let continue__= ref true in
  let request_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.token <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_envelope), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.request <- decode_request (Pbrt.Decoder.nested d); request_is_set := true;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_envelope), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !request_is_set then Pbrt.Decoder.missing_field "request" end;
  ({
    Vyconf_types.token = v.token;
    Vyconf_types.request = v.request;
  } : Vyconf_types.request_envelope)

let rec decode_status d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Vyconf_types.Success:Vyconf_types.status)
  | 1 -> (Vyconf_types.Fail:Vyconf_types.status)
  | 2 -> (Vyconf_types.Invalid_path:Vyconf_types.status)
  | 3 -> (Vyconf_types.Invalid_value:Vyconf_types.status)
  | 4 -> (Vyconf_types.Commit_in_progress:Vyconf_types.status)
  | 5 -> (Vyconf_types.Configuration_locked:Vyconf_types.status)
  | 6 -> (Vyconf_types.Internal_error:Vyconf_types.status)
  | 7 -> (Vyconf_types.Permission_denied:Vyconf_types.status)
  | 8 -> (Vyconf_types.Path_already_exists:Vyconf_types.status)
  | _ -> Pbrt.Decoder.malformed_variant "status"

let rec decode_response d =
  let v = default_response_mutable () in
  let continue__= ref true in
  let status_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.status <- decode_status d; status_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(response), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.output <- Some (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(response), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.error <- Some (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(response), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.warning <- Some (Pbrt.Decoder.string d);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(response), field(4)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !status_is_set then Pbrt.Decoder.missing_field "status" end;
  ({
    Vyconf_types.status = v.status;
    Vyconf_types.output = v.output;
    Vyconf_types.error = v.error;
    Vyconf_types.warning = v.warning;
  } : Vyconf_types.response)

let rec encode_request_config_format (v:Vyconf_types.request_config_format) encoder =
  match v with
  | Vyconf_types.Curly -> Pbrt.Encoder.int_as_varint (0) encoder
  | Vyconf_types.Json -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_request_output_format (v:Vyconf_types.request_output_format) encoder =
  match v with
  | Vyconf_types.Out_plain -> Pbrt.Encoder.int_as_varint (0) encoder
  | Vyconf_types.Out_json -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_request_setup_session (v:Vyconf_types.request_setup_session) encoder = 
  begin match v.Vyconf_types.client_application with
  | Some x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  begin match v.Vyconf_types.on_behalf_of with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    Pbrt.Encoder.int32_as_varint x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_set (v:Vyconf_types.request_set) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  begin match v.Vyconf_types.ephemeral with
  | Some x -> 
    Pbrt.Encoder.key 3 Pbrt.Varint encoder;
    Pbrt.Encoder.bool x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_delete (v:Vyconf_types.request_delete) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  ()

let rec encode_request_rename (v:Vyconf_types.request_rename) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.edit_level;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.from encoder;
  Pbrt.Encoder.key 3 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.to_ encoder;
  ()

let rec encode_request_copy (v:Vyconf_types.request_copy) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.edit_level;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.from encoder;
  Pbrt.Encoder.key 3 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.to_ encoder;
  ()

let rec encode_request_comment (v:Vyconf_types.request_comment) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.comment encoder;
  ()

let rec encode_request_commit (v:Vyconf_types.request_commit) encoder = 
  begin match v.Vyconf_types.confirm with
  | Some x -> 
    Pbrt.Encoder.key 1 Pbrt.Varint encoder;
    Pbrt.Encoder.bool x encoder;
  | None -> ();
  end;
  begin match v.Vyconf_types.confirm_timeout with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    Pbrt.Encoder.int32_as_varint x encoder;
  | None -> ();
  end;
  begin match v.Vyconf_types.comment with
  | Some x -> 
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_rollback (v:Vyconf_types.request_rollback) encoder = 
  Pbrt.Encoder.key 1 Pbrt.Varint encoder;
  Pbrt.Encoder.int32_as_varint v.Vyconf_types.revision encoder;
  ()

let rec encode_request_load (v:Vyconf_types.request_load) encoder = 
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.location encoder;
  begin match v.Vyconf_types.format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_config_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_merge (v:Vyconf_types.request_merge) encoder = 
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.location encoder;
  begin match v.Vyconf_types.format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_config_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_save (v:Vyconf_types.request_save) encoder = 
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.Vyconf_types.location encoder;
  begin match v.Vyconf_types.format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_config_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_show_config (v:Vyconf_types.request_show_config) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  begin match v.Vyconf_types.format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_config_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_exists (v:Vyconf_types.request_exists) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  ()

let rec encode_request_get_value (v:Vyconf_types.request_get_value) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  begin match v.Vyconf_types.output_format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_output_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_get_values (v:Vyconf_types.request_get_values) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  begin match v.Vyconf_types.output_format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_output_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_list_children (v:Vyconf_types.request_list_children) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  begin match v.Vyconf_types.output_format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_output_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_run_op_mode (v:Vyconf_types.request_run_op_mode) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  ) v.Vyconf_types.path;
  begin match v.Vyconf_types.output_format with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Varint encoder;
    encode_request_output_format x encoder;
  | None -> ();
  end;
  ()

let rec encode_request_enter_configuration_mode (v:Vyconf_types.request_enter_configuration_mode) encoder = 
  Pbrt.Encoder.key 1 Pbrt.Varint encoder;
  Pbrt.Encoder.bool v.Vyconf_types.exclusive encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder;
  Pbrt.Encoder.bool v.Vyconf_types.override_exclusive encoder;
  ()

let rec encode_request (v:Vyconf_types.request) encoder = 
  begin match v with
  | Vyconf_types.Status ->
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.empty_nested encoder
  | Vyconf_types.Setup_session x ->
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_setup_session x encoder;
  | Vyconf_types.Set x ->
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_set x encoder;
  | Vyconf_types.Delete x ->
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_delete x encoder;
  | Vyconf_types.Rename x ->
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_rename x encoder;
  | Vyconf_types.Copy x ->
    Pbrt.Encoder.key 6 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_copy x encoder;
  | Vyconf_types.Comment x ->
    Pbrt.Encoder.key 7 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_comment x encoder;
  | Vyconf_types.Commit x ->
    Pbrt.Encoder.key 8 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_commit x encoder;
  | Vyconf_types.Rollback x ->
    Pbrt.Encoder.key 9 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_rollback x encoder;
  | Vyconf_types.Merge x ->
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_merge x encoder;
  | Vyconf_types.Save x ->
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_save x encoder;
  | Vyconf_types.Show_config x ->
    Pbrt.Encoder.key 12 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_show_config x encoder;
  | Vyconf_types.Exists x ->
    Pbrt.Encoder.key 13 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_exists x encoder;
  | Vyconf_types.Get_value x ->
    Pbrt.Encoder.key 14 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_get_value x encoder;
  | Vyconf_types.Get_values x ->
    Pbrt.Encoder.key 15 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_get_values x encoder;
  | Vyconf_types.List_children x ->
    Pbrt.Encoder.key 16 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_list_children x encoder;
  | Vyconf_types.Run_op_mode x ->
    Pbrt.Encoder.key 17 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_run_op_mode x encoder;
  | Vyconf_types.Confirm ->
    Pbrt.Encoder.key 18 Pbrt.Bytes encoder;
    Pbrt.Encoder.empty_nested encoder
  | Vyconf_types.Configure x ->
    Pbrt.Encoder.key 19 Pbrt.Bytes encoder;
    Pbrt.Encoder.nested encode_request_enter_configuration_mode x encoder;
  | Vyconf_types.Exit_configure ->
    Pbrt.Encoder.key 20 Pbrt.Bytes encoder;
    Pbrt.Encoder.empty_nested encoder
  | Vyconf_types.Teardown x ->
    Pbrt.Encoder.key 21 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  end

let rec encode_request_envelope (v:Vyconf_types.request_envelope) encoder = 
  begin match v.Vyconf_types.token with
  | Some x -> 
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
  Pbrt.Encoder.nested encode_request v.Vyconf_types.request encoder;
  ()

let rec encode_status (v:Vyconf_types.status) encoder =
  match v with
  | Vyconf_types.Success -> Pbrt.Encoder.int_as_varint (0) encoder
  | Vyconf_types.Fail -> Pbrt.Encoder.int_as_varint 1 encoder
  | Vyconf_types.Invalid_path -> Pbrt.Encoder.int_as_varint 2 encoder
  | Vyconf_types.Invalid_value -> Pbrt.Encoder.int_as_varint 3 encoder
  | Vyconf_types.Commit_in_progress -> Pbrt.Encoder.int_as_varint 4 encoder
  | Vyconf_types.Configuration_locked -> Pbrt.Encoder.int_as_varint 5 encoder
  | Vyconf_types.Internal_error -> Pbrt.Encoder.int_as_varint 6 encoder
  | Vyconf_types.Permission_denied -> Pbrt.Encoder.int_as_varint 7 encoder
  | Vyconf_types.Path_already_exists -> Pbrt.Encoder.int_as_varint 8 encoder

let rec encode_response (v:Vyconf_types.response) encoder = 
  Pbrt.Encoder.key 1 Pbrt.Varint encoder;
  encode_status v.Vyconf_types.status encoder;
  begin match v.Vyconf_types.output with
  | Some x -> 
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  begin match v.Vyconf_types.error with
  | Some x -> 
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  begin match v.Vyconf_types.warning with
  | Some x -> 
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder;
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  ()
