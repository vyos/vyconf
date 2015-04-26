exception Duplicate_value

type config_node_data = {
  values : string list;
  comment : string;
  node_type : Vytree.node_type;
  keep_order : bool;
}

type t = config_node_data Vytree.t

val default_data : config_node_data

val make : string -> config_node_data Vytree.t

val set_value :
  config_node_data Vytree.t ->
  string list -> string -> config_node_data Vytree.t

val add_value :
  config_node_data Vytree.t ->
  string list -> string -> config_node_data Vytree.t

val get_values :
  config_node_data Vytree.t ->
  string list -> string list
