type node_type = Leaf | Tag | Other

type ref_node_data = {
    node_type: node_type;
    constraints: (Value_checker.value_constraint list);
    help: string;
    value_help: (string * string) list;
    constraint_error_message: string;
    multi: bool;
    valueless: bool;
    owner: string option;
    keep_order: bool;
    hidden: bool;
    secret: bool;
}

exception Bad_interface_definition of string

exception Validation_error of string

type t = ref_node_data Vytree.t

val default_data : ref_node_data

val default : t

val load_from_xml : t -> string -> t

val validate_path : string -> t -> string list -> string list * string option

val is_multi : t -> string list -> bool

val is_hidden : t -> string list -> bool

val is_secret : t -> string list -> bool

val is_tag : t -> string list -> bool

val is_leaf : t -> string list -> bool

val is_valueless : t -> string list -> bool

val get_keep_order : t -> string list -> bool

val get_owner : t -> string list -> string option

val get_help_string : t -> string list -> string

val get_value_help : t -> string list -> (string * string) list

val get_completion_data : t -> string list -> (node_type * bool * string) list
