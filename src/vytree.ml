type 'a	t = {
    name: string;
    data: 'a;
    children: 'a t list
}

type position = Before of string | After of string | End | Default

type node_type = Leaf | Tag | Other

exception Empty_path
exception Duplicate_child
exception Nonexistent_path
exception Insert_error of string

let make data name = { name = name; data = data; children = [] }

let make_full data name children = { name = name; data = data; children = children }

let name_of_node node = node.name
let data_of_node node = node.data
let children_of_node node = node.children

let insert_immediate ?(position=Default) node name data =
    let new_node = make data name in
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

let rec insert ?(position=Default) node path data =
    match path with
    | [] -> raise Empty_path
    | [name] ->
       (let last_child = find node name in
        match last_child with
        | None -> insert_immediate ~position:position node name data
        | (Some _) -> raise Duplicate_child)
    | name :: names ->
        let next_child = find node name in
        match next_child with
        | Some next_child' ->
            let new_node = insert next_child' names data in
            replace node new_node
        | None ->
            raise (Insert_error "Path does not exist")

let delete node path =
    do_with_child delete_immediate node path

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
