val find : ('a -> bool) -> 'a list -> 'a option
val remove : ('a -> bool) -> 'a list -> 'a list
val replace : ('a -> bool) -> 'a -> 'a list -> 'a list
val insert_before : ('a -> bool) -> 'a -> 'a list -> 'a list
val insert_after : ('a -> bool) -> 'a -> 'a list -> 'a	list
val complement : 'a list -> 'a list -> 'a list option
