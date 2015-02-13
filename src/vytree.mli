type 'a t

exception Empty_path
exception Duplicate_child
exception Nonexistent_path

val make : string -> 'a -> 'a t

val name_of_node : 'a t -> string
val data_of_node : 'a t -> 'a
val children_of_node : 'a t -> 'a t list

val insert_child :
  'a -> 'a t -> string list -> 'a -> 'a t

val list_children : 'a t -> string list
