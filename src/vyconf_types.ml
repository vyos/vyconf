[@@@ocaml.warning "-27-30-39"]


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

let rec default_request_config_format () = (Curly:request_config_format)

let rec default_request_output_format () = (Out_plain:request_output_format)

let rec default_request_setup_session 
  ?client_application:((client_application:string option) = None)
  ?on_behalf_of:((on_behalf_of:int32 option) = None)
  () : request_setup_session  = {
  client_application;
  on_behalf_of;
}

let rec default_request_set 
  ?path:((path:string list) = [])
  ?ephemeral:((ephemeral:bool option) = None)
  () : request_set  = {
  path;
  ephemeral;
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

let rec default_request_enter_configuration_mode 
  ?exclusive:((exclusive:bool) = false)
  ?override_exclusive:((override_exclusive:bool) = false)
  () : request_enter_configuration_mode  = {
  exclusive;
  override_exclusive;
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
