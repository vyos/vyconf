type value_behaviour = AddValue | ReplaceValue

exception Duplicate_value
exception Node_has_no_value
exception No_such_value
exception Useless_set

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

(** Interface to two rendering routines:
    1. The stand-alone routine, when [reftree] is not provided
    2. The reference-tree guided routine, when [reftree] is provided.

    If an {i incomplete} reftree is supplied, then the remaining portion of the
    config tree will be rendered according to the stand-alone routine.

    If an {i incompatible} reftree is supplied (i.e., the name of the nodes of
    the reftree do not match the name of the nodes in the config tree), then the
    exception {! Config_tree.Renderer.Inapt_reftree} is raised.

    @param indent spaces by which each level of nesting should be indented
    @param reftree optional reference tree used to instruct rendering
    @param cmp function used to sort the order of children, overruled
           if [reftree] specifies [keep_order] for a node
    @param showephemeral boolean determining whether ephemeral nodes are shown
    @param showinactive boolean determining whether inactive nodes are shown
*)
val render :
    ?indent:int ->
    ?reftree:(Reference_tree.t option)->
    ?cmp:(string -> string -> int) ->
    ?showephemeral:bool ->
    ?showinactive:bool ->
    t ->
    string

val render_at_level :
    ?indent:int ->
    ?reftree:(Reference_tree.t option)->
    ?cmp:(string -> string -> int) ->
    ?showephemeral:bool ->
    ?showinactive:bool ->
    t ->
    string list ->
    string

