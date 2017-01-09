type value_behaviour = AddValue | ReplaceValue

exception Duplicate_value
exception Node_has_no_value

type config_node_data = {
  values : string list;
  comment : string option;
  inactive : bool;
  ephemeral : bool;
} [@@deriving yojson]

type t = config_node_data Vytree.t [@@deriving yojson]

val default_data : config_node_data

val make : string -> t

val set : t -> string list -> string option -> value_behaviour -> t

val delete : t -> string list -> string option -> t

val get_values : t -> string list -> string list

val get_value : t -> string list -> string

val set_comment : t -> string list -> string option -> t

val get_comment : t -> string list -> string option

val set_inactive : t -> string list -> bool -> t

val is_inactive : t -> string list -> bool

val set_ephemeral : t -> string list -> bool -> t

val is_ephemeral : t -> string list -> bool
