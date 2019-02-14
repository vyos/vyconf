type 'a	t = {
    name: string;
    data: 'a;
    children: 'a t list
} [@@deriving yojson]

type position = Before of string | After of string | End | Default

exception Empty_path
exception Duplicate_child
exception Nonexistent_path
exception Insert_error of string

let make data name = { name = name; data = data; children = [] }

let make_full data name children = { name = name; data = data; children = children }

let name_of_node node = node.name
let data_of_node node = node.data
let children_of_node node = node.children

let insert_immediate ?(position=Default) node name data children =
    let new_node = make_full data name children in
    let children' =
        match position with
        | Default -> new_node :: node.children
        | End -> node.children @ [new_node]
        | Before s -> Vylist.insert_before (fun x -> x.name = s) new_node node.children
        | After s -> Vylist.insert_after (fun x -> x.name = s) new_node node.children
    in { node with children = children' }

let delete_immediate node name =
    let children' = Vylist.remove (fun x -> x.name = name) node.children in
    { node with children = children' }

let adopt node child =
    { node with children = child :: node.children }

let replace node child =
    let children = node.children in
    let name = child.name in
    let children' = Vylist.replace (fun x -> x.name = name) child children in
    { node with children = children' }

let replace_full node child name =
    let children = node.children in
    let children' = Vylist.replace (fun x -> x.name = name) child children in
    { node with children = children' }

let find node name =
    Vylist.find (fun x -> x.name = name) node.children

let find_or_fail node name =
    let child = find node name in
    match child with
    | None -> raise Nonexistent_path
    | Some child' -> child'

let list_children node =
    List.map (fun x -> x.name) node.children

let rec do_with_child fn node path =
    match path with
    | [] -> raise Empty_path
    | [name] -> fn node name
    | name :: names ->
        let next_child = find_or_fail node name in
        let new_node = do_with_child fn next_child names in
        replace node new_node

let rec insert ?(position=Default) ?(children=[]) node path data =
    match path with
    | [] -> raise Empty_path
    | [name] ->
       (let last_child = find node name in
        match last_child with
        | None -> insert_immediate ~position:position node name data children
        | (Some _) -> raise Duplicate_child)
    | name :: names ->
        let next_child = find node name in
        match next_child with
        | Some next_child' ->
            let new_node = insert ~position:position ~children:children next_child' names data in
            replace node new_node
        | None ->
            raise (Insert_error "Path does not exist")

(** Given a node N check if it has children with duplicate names,
    and merge subsequent children's children into the first child by
    that name.

    While all insert functions maintain the "every child has unique name"
    invariant, for nodes constructed manually with make/make_full and adopt
    it may not hold, and constructing nodes this way is a sensible approach
    for config parsing. Depending on the config format, duplicate node names
    may be normal and even expected, such as "ethernet eth0" and "ethernet eth1"
    in the "curly" format.
 *)
let merge_children merge_data node =
    (* Given a node N and a list of nodes NS, find all nodes in NS that
       have the same name as N and merge their children into N *)
    let rec merge_into n ns =
        match ns with
        | [] -> n
        | n' :: ns' ->
            if n.name = n'.name then
                let children = List.append n.children n'.children in
                let data = merge_data n.data n'.data in
                let n = {n with children=children; data=data} in
                merge_into n ns'
            else merge_into n ns'
    in
    (* Given a list of nodes, for every node, find subsequent children with
       the same name and merge them into the first node, then delete remaining
       nodes from the list *)
    let rec aux ns =
        match ns with
        | [] -> []
        | n :: ns ->
            let n = merge_into n ns in
            let ns = List.filter (fun x -> x.name <> n.name) ns in
            n :: (aux ns)
    in {node with children=(aux node.children)}

(* When inserting at a path that, entirely or partially,
   does not exist yet, create missing nodes on the way with default data *)
let rec insert_multi_level default_data node path_done path_remaining data =
    match path_remaining with
    | [] | [_] -> insert node (path_done @ path_remaining) data
    | name :: names ->
        let path_done = path_done @ [name] in
        let node = insert node path_done default_data in
        insert_multi_level default_data node path_done names data

let delete node path =
    do_with_child delete_immediate node path

let rename node path newname =
    let rename_immediate newname' node' name' =
        let child = find_or_fail node' name' in
        let child = { child with name=newname' } in
        replace_full node' child name'
    in do_with_child (rename_immediate newname) node path

let update node path data =
    let update_data data' node' name =
        let child = find_or_fail node' name in
        let child = { child with data=data' } in
        replace node' child
    in do_with_child (update_data data) node path

let rec get node path =
    match path with
    | [] -> raise Empty_path
    | [name] -> find_or_fail node name
    | name :: names -> get (find_or_fail node name) names

let get_data node path = data_of_node @@ get node path

let exists node path =
    try ignore (get node path); true
    with Nonexistent_path -> false

let get_existent_path node path =
    let rec aux node path acc =
        match path with
        | [] -> acc
        | name :: names ->
            let child = find node name in
            match child with
            | None -> acc
            | Some c -> aux c names (name :: acc)
    in List.rev (aux node path [])

let children_of_path node path =
    let node' = get node path in
    list_children node'

let sorted_children_of_node cmp node =
    let names = list_children node in
    let names = List.sort cmp names in
    List.map (find_or_fail node) names

let copy node old_path new_path =
    if exists node new_path then raise Duplicate_child else
    let child = get node old_path in
    insert ~position:End ~children:child.children node new_path child.data

let move node path position =
    let child = get node path in
    let node = delete node path in
    insert ~position:position ~children:child.children node path child.data
