type operation = {
    method_name: string;
    path: string list option;
    options: (string * string) list option
}

type message = {
    session_id: string;
    ops: operation list;
}

val operation_to_yojson : operation -> Yojson.Safe.json
val operation_of_yojson : Yojson.Safe.json -> [ `Error of bytes | `Ok of operation ]

val message_to_yojson : message -> Yojson.Safe.json
val message_of_yojson : Yojson.Safe.json -> [ `Error of bytes | `Ok of message ]
