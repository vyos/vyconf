type 'a t

exception Empty_path
exception Duplicate_child
exception Nonexistent_path

val make : string -> 'a -> 'a t
val make_full : string -> 'a -> ('a t) list -> 'a t

val name_of_node : 'a t -> string
val data_of_node : 'a t -> 'a
val children_of_node : 'a t -> 'a t list

val insert : 'a -> 'a t -> string list -> 'a -> 'a t

val delete : 'a t -> string list -> 'a t

val update : 'a t -> string list -> 'a -> 'a t

val list_children : 'a t -> string list

val get : 'a t -> string list -> 'a t
