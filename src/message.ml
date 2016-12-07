exception Invalid_operation of string
exception Invalid_message of string

type operation =
    | Set of string list
    | Delete of string list
    | Show of (string list option) * ((string * string) list option)
    | GetValues of string list
    | Commit

type request = {
    session_id: string;
    operations: operation list;
}

type response = {
    errors: string list;
    warnings: string list;
    data: string list;
} [@@deriving yojson]

type raw_operation = {
    method_name: string;
    path: string list option;
    options: (string * string) list option
} [@@deriving yojson]

type raw_request = {
    raw_session_id: string;
    raw_operations: raw_operation list;
} [@@deriving yojson]


let value_of_path p =
    match p with
    | Some p -> p
    | None -> raise (Invalid_operation "Operation requires a path")

let decode_operation op =
    let op_name = op.method_name in
    match op_name with
    | "set" -> Set (value_of_path op.path)
    | "delete" -> Delete (value_of_path op.path)
    | "show" -> Show (op.path, op.options)
    | "get_values" ->
        (match op.path with
         | Some path -> GetValues path
         | None -> raise (Invalid_operation "Operation requires a path"))
    | "commit" -> Commit
    | _ -> raise (Invalid_operation "Invalid operation name")

let encode_raw_operation op =
    match op with
    | Set path -> {method_name = "set"; path = Some path; options = None}
    | Delete path -> {method_name = "delete"; path = Some path; options = None}
    | Show (path, options) -> {method_name = "show"; path = path; options = options}
    | Commit -> {method_name = "commit"; path = None; options = None}
    | _ -> raise (Invalid_operation "Unimplemented")

let decode_request j =
    let req = raw_request_of_yojson j in
    match req with
    | Result.Ok req -> {session_id=req.raw_session_id; operations=(List.map decode_operation req.raw_operations)}
    | Result.Error str -> raise (Invalid_message str)

let encode_request req = 
    let raw_req = {raw_session_id=req.session_id; raw_operations=(List.map encode_raw_operation req.operations)} in
    raw_request_to_yojson raw_req

let encode_response = response_to_yojson

let decode_response j = 
    let result = response_of_yojson j in
    match result with
    | Result.Ok response -> response
    | Result.Error str -> raise (Invalid_message str)
