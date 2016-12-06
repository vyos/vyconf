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
    operations: operation list
}

type response = {
    errors: string list;
    warnings: string list;
    data: string list
}

type raw_operation = {
    method_name: string;
    path: string list option;
    options: (string * string) list option
}

type raw_request = {
    raw_session_id: string;
    raw_operations: raw_operation list
}

val encode_request : request -> Yojson.Safe.json
val decode_request : Yojson.Safe.json -> request

val encode_response : response -> Yojson.Safe.json
val decode_response : Yojson.Safe.json -> response

