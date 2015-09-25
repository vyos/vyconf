type 'a t

exception Empty_path
exception Duplicate_child
exception Nonexistent_path
exception Insert_error of string

type position = Before of string | After of string | End | Default

val make : 'a -> string -> 'a t
val make_full : 'a -> string -> ('a t) list -> 'a t

val name_of_node : 'a t -> string
val data_of_node : 'a t -> 'a
val children_of_node : 'a t -> 'a t list

val find : 'a t -> string -> 'a t option
val find_or_fail : 'a t -> string -> 'a t

val insert : ?position:position -> 'a t -> string list -> 'a -> 'a t

val insert_multi_level : 'a -> 'a t -> string list -> string list -> 'a -> 'a t

val delete : 'a t -> string list -> 'a t

val update : 'a t -> string list -> 'a -> 'a t

val list_children : 'a t -> string list

val get : 'a t -> string list -> 'a t

val get_existent_path : 'a t -> string list -> string list

val get_data : 'a t -> string list -> 'a

val exists : 'a t -> string list -> bool
