type value_constraint = Regex of string | External of string * string option

exception Bad_validator of string

val validate_value : string -> value_constraint -> string -> bool

val validate_any : string -> value_constraint list -> string -> bool
