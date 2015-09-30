exception Invalid_operation of string
exception Invalid_message of string

type operation =
    | Set of string list
    | Delete of string list
    | Show of (string list option) * ((string * string) list option)
    | GetValues of string list

type message = {
    session_id: string;
    ops: operation list
}

val decode : Yojson.Safe.json -> message
