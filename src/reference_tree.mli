type ref_node_data = {
    node_type: Vytree.node_type;
    constraints: (Value_checker.value_constraint list);
    help: string;
    value_help: (string * string) list;
    constraint_error_message: string;
    multi: bool;
    valueless: bool;
    owner: string option;
}

type t = ref_node_data Vytree.t

val default_data : ref_node_data

val load_from_xml : t -> string -> t
