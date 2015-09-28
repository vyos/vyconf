type operation = {
    method_name: string;
    path: string list option;
    value: string option;
    options: (string * string) list option
} [@@deriving yojson]

type message = {
    session_id: string;
    ops: operation list;
} [@@deriving yojson]
