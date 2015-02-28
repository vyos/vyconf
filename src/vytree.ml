type 'a	vyconf_tree = {
    name: string;
    data: 'a;
    children: 'a vyconf_tree list
}

type 'a t = 'a vyconf_tree

exception Empty_path
exception Duplicate_child
exception Nonexistent_path

let make name data = { name = name; data = data; children = [] }

let make_full name data children = { name = name; data = data; children = children }

let name_of_node node = node.name
let data_of_node node = node.data
let children_of_node node = node.children

let insert_immediate_child node name data =
    let new_node = make name data in
    let children' = node.children @ [new_node] in
    { node with children = children' }

let delete_immediate_child node name =
    let children' = Vylist.remove (fun x -> x.name = name) node.children in
    { node with children = children' }

let adopt_child node child =
    { node with children = (node.children @ [child]) }

let replace_child node child =
    let children = node.children in
    let name = child.name in
    let children' = Vylist.replace (fun x -> x.name = name) child children in
    { node with children = children' }

let find_child node name =
    Vylist.find (fun x -> x.name = name) node.children

let rec extract_names children =
    List.map (fun x -> x.name) children

let list_children node =
    extract_names node.children

let rec insert_child default_data node path data =
    match path with
    | [] -> raise Empty_path
    | [name] ->
        begin
            (* Check for duplicate item *)
            let last_child = find_child node name in
            match last_child with
            | None -> insert_immediate_child node name data
            | (Some _) -> raise Duplicate_child
        end
    | name :: names ->
        let next_child = find_child node name in
        match next_child with
        | Some next_child' ->
            let new_node = insert_child default_data next_child' names data in
            replace_child node new_node
        | None ->
            let next_child' = make name default_data in
            let new_node = insert_child default_data next_child' names data in
            adopt_child node new_node

let rec delete_child node path =
    match path with
    | [] -> raise Empty_path
    | [name] -> delete_immediate_child node name
    | name :: names ->
        let next_child = find_child node name in
        match next_child with
        | None -> raise Nonexistent_path
        | Some next_child' -> 
            let new_node = delete_child next_child' names in
            replace_child node new_node

let rec get_child node path =
    match path with
    | [] -> raise Empty_path
    | [name] ->
        begin
            let child = find_child node name in
            match child with
            | None -> raise Nonexistent_path
            | Some child' -> child'
        end
    | name :: names ->
        begin
            let next_child = find_child node name in
            match next_child with
            | None -> raise Nonexistent_path
            | Some child' -> get_child child' names
        end
