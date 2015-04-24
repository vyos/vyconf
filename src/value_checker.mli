type value_constraint = Regex of string | External of string * string

exception Bad_validator of string

val validate_value : (string, string) Hashtbl.t -> value_constraint -> string -> bool

val validate_any : (string, string) Hashtbl.t -> value_constraint list -> string -> bool
