type value_behaviour = AddValue | ReplaceValue

exception Duplicate_value
exception Node_has_no_value

type config_node_data = {
  values : string list;
  comment : string;
}

type t = config_node_data Vytree.t

val default_data : config_node_data

val make : string -> t

val set : t -> string list -> string -> value_behaviour -> t

val delete : t -> string list -> string option -> t

val get_values : t -> string list -> string list

val get_value : t -> string list -> string
