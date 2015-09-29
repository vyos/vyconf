exception Invalid_operation of string
exception Invalid_message of string

type operation =
    | Set of string list
    | Delete of string list
    | Show of (string list option) * ((string * string) list option)

type message = {
    session_id: string;
    ops: operation list
}

type raw_operation = {
    method_name: string;
    path: string list option;
    options: (string * string) list option
} [@@deriving yojson]

type raw_message = {
    raw_session_id: string;
    raw_ops: raw_operation list;
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
    | _ -> raise (Invalid_operation "Invalid operation name")

let decode_message msg =
    let id = msg.raw_session_id in
    let ops = List.map decode_operation msg.raw_ops in
    {session_id = id; ops = ops}

let decode j =
    let msg = raw_message_of_yojson j in
    match msg with
    | `Ok msg -> decode_message msg
    | `Error str -> raise (Invalid_message str)
    
