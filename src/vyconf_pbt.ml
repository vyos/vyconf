[@@@ocaml.warning "-27-30-39-44"]

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

type request_reload_reftree = {
  on_behalf_of : int32 option;
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
  | Validate of request_validate
  | Teardown of request_teardown
  | Reload_reftree of request_reload_reftree

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

let rec default_request_config_format () = (Curly:request_config_format)

let rec default_request_output_format () = (Out_plain:request_output_format)

let rec default_request_status = ()

let rec default_request_setup_session 
  ?client_application:((client_application:string option) = None)
  ?on_behalf_of:((on_behalf_of:int32 option) = None)
  () : request_setup_session  = {
  client_application;
  on_behalf_of;
}

let rec default_request_teardown 
  ?on_behalf_of:((on_behalf_of:int32 option) = None)
  () : request_teardown  = {
  on_behalf_of;
}

let rec default_request_validate 
  ?path:((path:string list) = [])
  ?output_format:((output_format:request_output_format option) = None)
  () : request_validate  = {
  path;
  output_format;
}

let rec default_request_set 
  ?path:((path:string list) = [])
  () : request_set  = {
  path;
}

let rec default_request_delete 
  ?path:((path:string list) = [])
  () : request_delete  = {
  path;
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

let rec default_request_copy 
  ?edit_level:((edit_level:string list) = [])
  ?from:((from:string) = "")
  ?to_:((to_:string) = "")
  () : request_copy  = {
  edit_level;
  from;
  to_;
}

let rec default_request_comment 
  ?path:((path:string list) = [])
  ?comment:((comment:string) = "")
  () : request_comment  = {
  path;
  comment;
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

let rec default_request_rollback 
  ?revision:((revision:int32) = 0l)
  () : request_rollback  = {
  revision;
}

let rec default_request_load 
  ?location:((location:string) = "")
  ?format:((format:request_config_format option) = None)
  () : request_load  = {
  location;
  format;
}

let rec default_request_merge 
  ?location:((location:string) = "")
  ?format:((format:request_config_format option) = None)
  () : request_merge  = {
  location;
  format;
}

let rec default_request_save 
  ?location:((location:string) = "")
  ?format:((format:request_config_format option) = None)
  () : request_save  = {
  location;
  format;
}

let rec default_request_show_config 
  ?path:((path:string list) = [])
  ?format:((format:request_config_format option) = None)
  () : request_show_config  = {
  path;
  format;
}

let rec default_request_exists 
  ?path:((path:string list) = [])
  () : request_exists  = {
  path;
}

let rec default_request_get_value 
  ?path:((path:string list) = [])
  ?output_format:((output_format:request_output_format option) = None)
  () : request_get_value  = {
  path;
  output_format;
}

let rec default_request_get_values 
  ?path:((path:string list) = [])
  ?output_format:((output_format:request_output_format option) = None)
  () : request_get_values  = {
  path;
  output_format;
}

let rec default_request_list_children 
  ?path:((path:string list) = [])
  ?output_format:((output_format:request_output_format option) = None)
  () : request_list_children  = {
  path;
  output_format;
}

let rec default_request_run_op_mode 
  ?path:((path:string list) = [])
  ?output_format:((output_format:request_output_format option) = None)
  () : request_run_op_mode  = {
  path;
  output_format;
}

let rec default_request_confirm = ()

let rec default_request_enter_configuration_mode 
  ?exclusive:((exclusive:bool) = false)
  ?override_exclusive:((override_exclusive:bool) = false)
  () : request_enter_configuration_mode  = {
  exclusive;
  override_exclusive;
}

let rec default_request_exit_configuration_mode = ()

let rec default_request_reload_reftree 
  ?on_behalf_of:((on_behalf_of:int32 option) = None)
  () : request_reload_reftree  = {
  on_behalf_of;
}

let rec default_request (): request = Status

let rec default_request_envelope 
  ?token:((token:string option) = None)
  ?request:((request:request) = default_request ())
  () : request_envelope  = {
  token;
  request;
}

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

type request_setup_session_mutable = {
  mutable client_application : string option;
  mutable on_behalf_of : int32 option;
}

let default_request_setup_session_mutable () : request_setup_session_mutable = {
  client_application = None;
  on_behalf_of = None;
}

type request_teardown_mutable = {
  mutable on_behalf_of : int32 option;
}

let default_request_teardown_mutable () : request_teardown_mutable = {
  on_behalf_of = None;
}

type request_validate_mutable = {
  mutable path : string list;
  mutable output_format : request_output_format option;
}

let default_request_validate_mutable () : request_validate_mutable = {
  path = [];
  output_format = None;
}

type request_set_mutable = {
  mutable path : string list;
}

let default_request_set_mutable () : request_set_mutable = {
  path = [];
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
  mutable format : request_config_format option;
}

let default_request_load_mutable () : request_load_mutable = {
  location = "";
  format = None;
}

type request_merge_mutable = {
  mutable location : string;
  mutable format : request_config_format option;
}

let default_request_merge_mutable () : request_merge_mutable = {
  location = "";
  format = None;
}

type request_save_mutable = {
  mutable location : string;
  mutable format : request_config_format option;
}

let default_request_save_mutable () : request_save_mutable = {
  location = "";
  format = None;
}

type request_show_config_mutable = {
  mutable path : string list;
  mutable format : request_config_format option;
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
  mutable output_format : request_output_format option;
}

let default_request_get_value_mutable () : request_get_value_mutable = {
  path = [];
  output_format = None;
}

type request_get_values_mutable = {
  mutable path : string list;
  mutable output_format : request_output_format option;
}

let default_request_get_values_mutable () : request_get_values_mutable = {
  path = [];
  output_format = None;
}

type request_list_children_mutable = {
  mutable path : string list;
  mutable output_format : request_output_format option;
}

let default_request_list_children_mutable () : request_list_children_mutable = {
  path = [];
  output_format = None;
}

type request_run_op_mode_mutable = {
  mutable path : string list;
  mutable output_format : request_output_format option;
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

type request_reload_reftree_mutable = {
  mutable on_behalf_of : int32 option;
}

let default_request_reload_reftree_mutable () : request_reload_reftree_mutable = {
  on_behalf_of = None;
}

type request_envelope_mutable = {
  mutable token : string option;
  mutable request : request;
}

let default_request_envelope_mutable () : request_envelope_mutable = {
  token = None;
  request = default_request ();
}

type response_mutable = {
  mutable status : status;
  mutable output : string option;
  mutable error : string option;
  mutable warning : string option;
}

let default_response_mutable () : response_mutable = {
  status = default_status ();
  output = None;
  error = None;
  warning = None;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_request_config_format fmt (v:request_config_format) =
  match v with
  | Curly -> Format.fprintf fmt "Curly"
  | Json -> Format.fprintf fmt "Json"

let rec pp_request_output_format fmt (v:request_output_format) =
  match v with
  | Out_plain -> Format.fprintf fmt "Out_plain"
  | Out_json -> Format.fprintf fmt "Out_json"

let rec pp_request_status fmt (v:request_status) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_setup_session fmt (v:request_setup_session) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "client_application" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.client_application;
    Pbrt.Pp.pp_record_field ~first:false "on_behalf_of" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.on_behalf_of;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_teardown fmt (v:request_teardown) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "on_behalf_of" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.on_behalf_of;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_validate fmt (v:request_validate) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "output_format" (Pbrt.Pp.pp_option pp_request_output_format) fmt v.output_format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_set fmt (v:request_set) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_delete fmt (v:request_delete) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_rename fmt (v:request_rename) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "edit_level" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.edit_level;
    Pbrt.Pp.pp_record_field ~first:false "from" Pbrt.Pp.pp_string fmt v.from;
    Pbrt.Pp.pp_record_field ~first:false "to_" Pbrt.Pp.pp_string fmt v.to_;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_copy fmt (v:request_copy) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "edit_level" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.edit_level;
    Pbrt.Pp.pp_record_field ~first:false "from" Pbrt.Pp.pp_string fmt v.from;
    Pbrt.Pp.pp_record_field ~first:false "to_" Pbrt.Pp.pp_string fmt v.to_;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_comment fmt (v:request_comment) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "comment" Pbrt.Pp.pp_string fmt v.comment;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_commit fmt (v:request_commit) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "confirm" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.confirm;
    Pbrt.Pp.pp_record_field ~first:false "confirm_timeout" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.confirm_timeout;
    Pbrt.Pp.pp_record_field ~first:false "comment" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.comment;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_rollback fmt (v:request_rollback) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "revision" Pbrt.Pp.pp_int32 fmt v.revision;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_load fmt (v:request_load) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "location" Pbrt.Pp.pp_string fmt v.location;
    Pbrt.Pp.pp_record_field ~first:false "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_merge fmt (v:request_merge) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "location" Pbrt.Pp.pp_string fmt v.location;
    Pbrt.Pp.pp_record_field ~first:false "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_save fmt (v:request_save) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "location" Pbrt.Pp.pp_string fmt v.location;
    Pbrt.Pp.pp_record_field ~first:false "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_show_config fmt (v:request_show_config) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "format" (Pbrt.Pp.pp_option pp_request_config_format) fmt v.format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_exists fmt (v:request_exists) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_get_value fmt (v:request_get_value) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "output_format" (Pbrt.Pp.pp_option pp_request_output_format) fmt v.output_format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_get_values fmt (v:request_get_values) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "output_format" (Pbrt.Pp.pp_option pp_request_output_format) fmt v.output_format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_list_children fmt (v:request_list_children) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "output_format" (Pbrt.Pp.pp_option pp_request_output_format) fmt v.output_format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_run_op_mode fmt (v:request_run_op_mode) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "path" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.path;
    Pbrt.Pp.pp_record_field ~first:false "output_format" (Pbrt.Pp.pp_option pp_request_output_format) fmt v.output_format;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_confirm fmt (v:request_confirm) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_enter_configuration_mode fmt (v:request_enter_configuration_mode) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "exclusive" Pbrt.Pp.pp_bool fmt v.exclusive;
    Pbrt.Pp.pp_record_field ~first:false "override_exclusive" Pbrt.Pp.pp_bool fmt v.override_exclusive;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_exit_configuration_mode fmt (v:request_exit_configuration_mode) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request_reload_reftree fmt (v:request_reload_reftree) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "on_behalf_of" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.on_behalf_of;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_request fmt (v:request) =
  match v with
  | Status  -> Format.fprintf fmt "Status"
  | Setup_session x -> Format.fprintf fmt "@[<hv2>Setup_session(@,%a)@]" pp_request_setup_session x
  | Set x -> Format.fprintf fmt "@[<hv2>Set(@,%a)@]" pp_request_set x
  | Delete x -> Format.fprintf fmt "@[<hv2>Delete(@,%a)@]" pp_request_delete x
  | Rename x -> Format.fprintf fmt "@[<hv2>Rename(@,%a)@]" pp_request_rename x
  | Copy x -> Format.fprintf fmt "@[<hv2>Copy(@,%a)@]" pp_request_copy x
  | Comment x -> Format.fprintf fmt "@[<hv2>Comment(@,%a)@]" pp_request_comment x
  | Commit x -> Format.fprintf fmt "@[<hv2>Commit(@,%a)@]" pp_request_commit x
  | Rollback x -> Format.fprintf fmt "@[<hv2>Rollback(@,%a)@]" pp_request_rollback x
  | Merge x -> Format.fprintf fmt "@[<hv2>Merge(@,%a)@]" pp_request_merge x
  | Save x -> Format.fprintf fmt "@[<hv2>Save(@,%a)@]" pp_request_save x
  | Show_config x -> Format.fprintf fmt "@[<hv2>Show_config(@,%a)@]" pp_request_show_config x
  | Exists x -> Format.fprintf fmt "@[<hv2>Exists(@,%a)@]" pp_request_exists x
  | Get_value x -> Format.fprintf fmt "@[<hv2>Get_value(@,%a)@]" pp_request_get_value x
  | Get_values x -> Format.fprintf fmt "@[<hv2>Get_values(@,%a)@]" pp_request_get_values x
  | List_children x -> Format.fprintf fmt "@[<hv2>List_children(@,%a)@]" pp_request_list_children x
  | Run_op_mode x -> Format.fprintf fmt "@[<hv2>Run_op_mode(@,%a)@]" pp_request_run_op_mode x
  | Confirm  -> Format.fprintf fmt "Confirm"
  | Configure x -> Format.fprintf fmt "@[<hv2>Configure(@,%a)@]" pp_request_enter_configuration_mode x
  | Exit_configure  -> Format.fprintf fmt "Exit_configure"
  | Validate x -> Format.fprintf fmt "@[<hv2>Validate(@,%a)@]" pp_request_validate x
  | Teardown x -> Format.fprintf fmt "@[<hv2>Teardown(@,%a)@]" pp_request_teardown x
  | Reload_reftree x -> Format.fprintf fmt "@[<hv2>Reload_reftree(@,%a)@]" pp_request_reload_reftree x

let rec pp_request_envelope fmt (v:request_envelope) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "token" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.token;
    Pbrt.Pp.pp_record_field ~first:false "request" pp_request fmt v.request;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

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
  | Path_already_exists -> Format.fprintf fmt "Path_already_exists"

let rec pp_response fmt (v:response) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "status" pp_status fmt v.status;
    Pbrt.Pp.pp_record_field ~first:false "output" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.output;
    Pbrt.Pp.pp_record_field ~first:false "error" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.error;
    Pbrt.Pp.pp_record_field ~first:false "warning" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.warning;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_request_config_format (v:request_config_format) encoder =
  match v with
  | Curly -> Pbrt.Encoder.int_as_varint (0) encoder
  | Json -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_request_output_format (v:request_output_format) encoder =
  match v with
  | Out_plain -> Pbrt.Encoder.int_as_varint (0) encoder
  | Out_json -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_request_status (v:request_status) encoder = 
()

let rec encode_pb_request_setup_session (v:request_setup_session) encoder = 
  begin match v.client_application with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.on_behalf_of with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_teardown (v:request_teardown) encoder = 
  begin match v.on_behalf_of with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_validate (v:request_validate) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  begin match v.output_format with
  | Some x -> 
    encode_pb_request_output_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_set (v:request_set) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  ()

let rec encode_pb_request_delete (v:request_delete) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  ()

let rec encode_pb_request_rename (v:request_rename) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.edit_level encoder;
  Pbrt.Encoder.string v.from encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.Encoder.string v.to_ encoder;
  Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_request_copy (v:request_copy) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.edit_level encoder;
  Pbrt.Encoder.string v.from encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.Encoder.string v.to_ encoder;
  Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_request_comment (v:request_comment) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  Pbrt.Encoder.string v.comment encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_request_commit (v:request_commit) encoder = 
  begin match v.confirm with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.confirm_timeout with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.comment with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_rollback (v:request_rollback) encoder = 
  Pbrt.Encoder.int32_as_varint v.revision encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  ()

let rec encode_pb_request_load (v:request_load) encoder = 
  Pbrt.Encoder.string v.location encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  begin match v.format with
  | Some x -> 
    encode_pb_request_config_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_merge (v:request_merge) encoder = 
  Pbrt.Encoder.string v.location encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  begin match v.format with
  | Some x -> 
    encode_pb_request_config_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_save (v:request_save) encoder = 
  Pbrt.Encoder.string v.location encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  begin match v.format with
  | Some x -> 
    encode_pb_request_config_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_show_config (v:request_show_config) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  begin match v.format with
  | Some x -> 
    encode_pb_request_config_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_exists (v:request_exists) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  ()

let rec encode_pb_request_get_value (v:request_get_value) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  begin match v.output_format with
  | Some x -> 
    encode_pb_request_output_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_get_values (v:request_get_values) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  begin match v.output_format with
  | Some x -> 
    encode_pb_request_output_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_list_children (v:request_list_children) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  begin match v.output_format with
  | Some x -> 
    encode_pb_request_output_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_run_op_mode (v:request_run_op_mode) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.path encoder;
  begin match v.output_format with
  | Some x -> 
    encode_pb_request_output_format x encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request_confirm (v:request_confirm) encoder = 
()

let rec encode_pb_request_enter_configuration_mode (v:request_enter_configuration_mode) encoder = 
  Pbrt.Encoder.bool v.exclusive encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.bool v.override_exclusive encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  ()

let rec encode_pb_request_exit_configuration_mode (v:request_exit_configuration_mode) encoder = 
()

let rec encode_pb_request_reload_reftree (v:request_reload_reftree) encoder = 
  begin match v.on_behalf_of with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_request (v:request) encoder = 
  begin match v with
  | Status ->
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Setup_session x ->
    Pbrt.Encoder.nested encode_pb_request_setup_session x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Set x ->
    Pbrt.Encoder.nested encode_pb_request_set x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Delete x ->
    Pbrt.Encoder.nested encode_pb_request_delete x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Rename x ->
    Pbrt.Encoder.nested encode_pb_request_rename x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  | Copy x ->
    Pbrt.Encoder.nested encode_pb_request_copy x encoder;
    Pbrt.Encoder.key 6 Pbrt.Bytes encoder; 
  | Comment x ->
    Pbrt.Encoder.nested encode_pb_request_comment x encoder;
    Pbrt.Encoder.key 7 Pbrt.Bytes encoder; 
  | Commit x ->
    Pbrt.Encoder.nested encode_pb_request_commit x encoder;
    Pbrt.Encoder.key 8 Pbrt.Bytes encoder; 
  | Rollback x ->
    Pbrt.Encoder.nested encode_pb_request_rollback x encoder;
    Pbrt.Encoder.key 9 Pbrt.Bytes encoder; 
  | Merge x ->
    Pbrt.Encoder.nested encode_pb_request_merge x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | Save x ->
    Pbrt.Encoder.nested encode_pb_request_save x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  | Show_config x ->
    Pbrt.Encoder.nested encode_pb_request_show_config x encoder;
    Pbrt.Encoder.key 12 Pbrt.Bytes encoder; 
  | Exists x ->
    Pbrt.Encoder.nested encode_pb_request_exists x encoder;
    Pbrt.Encoder.key 13 Pbrt.Bytes encoder; 
  | Get_value x ->
    Pbrt.Encoder.nested encode_pb_request_get_value x encoder;
    Pbrt.Encoder.key 14 Pbrt.Bytes encoder; 
  | Get_values x ->
    Pbrt.Encoder.nested encode_pb_request_get_values x encoder;
    Pbrt.Encoder.key 15 Pbrt.Bytes encoder; 
  | List_children x ->
    Pbrt.Encoder.nested encode_pb_request_list_children x encoder;
    Pbrt.Encoder.key 16 Pbrt.Bytes encoder; 
  | Run_op_mode x ->
    Pbrt.Encoder.nested encode_pb_request_run_op_mode x encoder;
    Pbrt.Encoder.key 17 Pbrt.Bytes encoder; 
  | Confirm ->
    Pbrt.Encoder.key 18 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Configure x ->
    Pbrt.Encoder.nested encode_pb_request_enter_configuration_mode x encoder;
    Pbrt.Encoder.key 19 Pbrt.Bytes encoder; 
  | Exit_configure ->
    Pbrt.Encoder.key 20 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Validate x ->
    Pbrt.Encoder.nested encode_pb_request_validate x encoder;
    Pbrt.Encoder.key 21 Pbrt.Bytes encoder; 
  | Teardown x ->
    Pbrt.Encoder.nested encode_pb_request_teardown x encoder;
    Pbrt.Encoder.key 22 Pbrt.Bytes encoder; 
  | Reload_reftree x ->
    Pbrt.Encoder.nested encode_pb_request_reload_reftree x encoder;
    Pbrt.Encoder.key 23 Pbrt.Bytes encoder; 
  end

let rec encode_pb_request_envelope (v:request_envelope) encoder = 
  begin match v.token with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.nested encode_pb_request v.request encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_status (v:status) encoder =
  match v with
  | Success -> Pbrt.Encoder.int_as_varint (0) encoder
  | Fail -> Pbrt.Encoder.int_as_varint 1 encoder
  | Invalid_path -> Pbrt.Encoder.int_as_varint 2 encoder
  | Invalid_value -> Pbrt.Encoder.int_as_varint 3 encoder
  | Commit_in_progress -> Pbrt.Encoder.int_as_varint 4 encoder
  | Configuration_locked -> Pbrt.Encoder.int_as_varint 5 encoder
  | Internal_error -> Pbrt.Encoder.int_as_varint 6 encoder
  | Permission_denied -> Pbrt.Encoder.int_as_varint 7 encoder
  | Path_already_exists -> Pbrt.Encoder.int_as_varint 8 encoder

let rec encode_pb_response (v:response) encoder = 
  encode_pb_status v.status encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  begin match v.output with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.error with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.warning with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_request_config_format d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Curly:request_config_format)
  | 1 -> (Json:request_config_format)
  | _ -> Pbrt.Decoder.malformed_variant "request_config_format"

let rec decode_pb_request_output_format d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Out_plain:request_output_format)
  | 1 -> (Out_json:request_output_format)
  | _ -> Pbrt.Decoder.malformed_variant "request_output_format"

let rec decode_pb_request_status d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(request_status)" pk

let rec decode_pb_request_setup_session d =
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
    client_application = v.client_application;
    on_behalf_of = v.on_behalf_of;
  } : request_setup_session)

let rec decode_pb_request_teardown d =
  let v = default_request_teardown_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.on_behalf_of <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_teardown), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    on_behalf_of = v.on_behalf_of;
  } : request_teardown)

let rec decode_pb_request_validate d =
  let v = default_request_validate_mutable () in
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
      Pbrt.Decoder.unexpected_payload "Message(request_validate), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.output_format <- Some (decode_pb_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_validate), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
    output_format = v.output_format;
  } : request_validate)

let rec decode_pb_request_set d =
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
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
  } : request_set)

let rec decode_pb_request_delete d =
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
    path = v.path;
  } : request_delete)

let rec decode_pb_request_rename d =
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
    edit_level = v.edit_level;
    from = v.from;
    to_ = v.to_;
  } : request_rename)

let rec decode_pb_request_copy d =
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
    edit_level = v.edit_level;
    from = v.from;
    to_ = v.to_;
  } : request_copy)

let rec decode_pb_request_comment d =
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
    path = v.path;
    comment = v.comment;
  } : request_comment)

let rec decode_pb_request_commit d =
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
    confirm = v.confirm;
    confirm_timeout = v.confirm_timeout;
    comment = v.comment;
  } : request_commit)

let rec decode_pb_request_rollback d =
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
    revision = v.revision;
  } : request_rollback)

let rec decode_pb_request_load d =
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
      v.format <- Some (decode_pb_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_load), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !location_is_set then Pbrt.Decoder.missing_field "location" end;
  ({
    location = v.location;
    format = v.format;
  } : request_load)

let rec decode_pb_request_merge d =
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
      v.format <- Some (decode_pb_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_merge), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !location_is_set then Pbrt.Decoder.missing_field "location" end;
  ({
    location = v.location;
    format = v.format;
  } : request_merge)

let rec decode_pb_request_save d =
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
      v.format <- Some (decode_pb_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_save), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !location_is_set then Pbrt.Decoder.missing_field "location" end;
  ({
    location = v.location;
    format = v.format;
  } : request_save)

let rec decode_pb_request_show_config d =
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
      v.format <- Some (decode_pb_request_config_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_show_config), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
    format = v.format;
  } : request_show_config)

let rec decode_pb_request_exists d =
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
    path = v.path;
  } : request_exists)

let rec decode_pb_request_get_value d =
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
      v.output_format <- Some (decode_pb_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_get_value), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
    output_format = v.output_format;
  } : request_get_value)

let rec decode_pb_request_get_values d =
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
      v.output_format <- Some (decode_pb_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_get_values), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
    output_format = v.output_format;
  } : request_get_values)

let rec decode_pb_request_list_children d =
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
      v.output_format <- Some (decode_pb_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_list_children), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
    output_format = v.output_format;
  } : request_list_children)

let rec decode_pb_request_run_op_mode d =
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
      v.output_format <- Some (decode_pb_request_output_format d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_run_op_mode), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    path = v.path;
    output_format = v.output_format;
  } : request_run_op_mode)

let rec decode_pb_request_confirm d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(request_confirm)" pk

let rec decode_pb_request_enter_configuration_mode d =
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
    exclusive = v.exclusive;
    override_exclusive = v.override_exclusive;
  } : request_enter_configuration_mode)

let rec decode_pb_request_exit_configuration_mode d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(request_exit_configuration_mode)" pk

let rec decode_pb_request_reload_reftree d =
  let v = default_request_reload_reftree_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.on_behalf_of <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_reload_reftree), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    on_behalf_of = v.on_behalf_of;
  } : request_reload_reftree)

let rec decode_pb_request d = 
  let rec loop () = 
    let ret:request = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "request"
      | Some (1, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Status : request)
      end
      | Some (2, _) -> (Setup_session (decode_pb_request_setup_session (Pbrt.Decoder.nested d)) : request) 
      | Some (3, _) -> (Set (decode_pb_request_set (Pbrt.Decoder.nested d)) : request) 
      | Some (4, _) -> (Delete (decode_pb_request_delete (Pbrt.Decoder.nested d)) : request) 
      | Some (5, _) -> (Rename (decode_pb_request_rename (Pbrt.Decoder.nested d)) : request) 
      | Some (6, _) -> (Copy (decode_pb_request_copy (Pbrt.Decoder.nested d)) : request) 
      | Some (7, _) -> (Comment (decode_pb_request_comment (Pbrt.Decoder.nested d)) : request) 
      | Some (8, _) -> (Commit (decode_pb_request_commit (Pbrt.Decoder.nested d)) : request) 
      | Some (9, _) -> (Rollback (decode_pb_request_rollback (Pbrt.Decoder.nested d)) : request) 
      | Some (10, _) -> (Merge (decode_pb_request_merge (Pbrt.Decoder.nested d)) : request) 
      | Some (11, _) -> (Save (decode_pb_request_save (Pbrt.Decoder.nested d)) : request) 
      | Some (12, _) -> (Show_config (decode_pb_request_show_config (Pbrt.Decoder.nested d)) : request) 
      | Some (13, _) -> (Exists (decode_pb_request_exists (Pbrt.Decoder.nested d)) : request) 
      | Some (14, _) -> (Get_value (decode_pb_request_get_value (Pbrt.Decoder.nested d)) : request) 
      | Some (15, _) -> (Get_values (decode_pb_request_get_values (Pbrt.Decoder.nested d)) : request) 
      | Some (16, _) -> (List_children (decode_pb_request_list_children (Pbrt.Decoder.nested d)) : request) 
      | Some (17, _) -> (Run_op_mode (decode_pb_request_run_op_mode (Pbrt.Decoder.nested d)) : request) 
      | Some (18, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Confirm : request)
      end
      | Some (19, _) -> (Configure (decode_pb_request_enter_configuration_mode (Pbrt.Decoder.nested d)) : request) 
      | Some (20, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Exit_configure : request)
      end
      | Some (21, _) -> (Validate (decode_pb_request_validate (Pbrt.Decoder.nested d)) : request) 
      | Some (22, _) -> (Teardown (decode_pb_request_teardown (Pbrt.Decoder.nested d)) : request) 
      | Some (23, _) -> (Reload_reftree (decode_pb_request_reload_reftree (Pbrt.Decoder.nested d)) : request) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

let rec decode_pb_request_envelope d =
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
      v.request <- decode_pb_request (Pbrt.Decoder.nested d); request_is_set := true;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(request_envelope), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !request_is_set then Pbrt.Decoder.missing_field "request" end;
  ({
    token = v.token;
    request = v.request;
  } : request_envelope)

let rec decode_pb_status d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Success:status)
  | 1 -> (Fail:status)
  | 2 -> (Invalid_path:status)
  | 3 -> (Invalid_value:status)
  | 4 -> (Commit_in_progress:status)
  | 5 -> (Configuration_locked:status)
  | 6 -> (Internal_error:status)
  | 7 -> (Permission_denied:status)
  | 8 -> (Path_already_exists:status)
  | _ -> Pbrt.Decoder.malformed_variant "status"

let rec decode_pb_response d =
  let v = default_response_mutable () in
  let continue__= ref true in
  let status_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.status <- decode_pb_status d; status_is_set := true;
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
    status = v.status;
    output = v.output;
    error = v.error;
    warning = v.warning;
  } : response)
