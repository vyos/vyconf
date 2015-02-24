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

let rec find_child_in_list children name =
    match children with
    | [] -> None
    | c :: cs -> if c.name = name then (Some c)
                 else find_child_in_list cs name

let rec remove_child_from_list children name =
    match children with
    | [] -> []
    | c :: cs -> if c.name = name then cs
                 else c :: (remove_child_from_list cs name)

let rec replace_child_in_list children child =
    match children with
    | [] -> []
    | c :: cs -> if c.name = child.name then child :: cs
                 else replace_child_in_list cs child

let extract_child children name =
    find_child_in_list children name,
    remove_child_from_list children name

let insert_immediate_child node name data =
    let new_node = make name data in
    let children' = node.children @ [new_node] in
    { node with children = children' }

let adopt_child node child =
    { node with children = (node.children @ [child]) }

let replace_child node child =
    let children = node.children in
    let children' = replace_child_in_list children child in
    { node with children = children' }

let find_child node name =
    find_child_in_list node.children name

let rec extract_names children =
    match children with
    | [] -> []
    | c :: cs -> c.name :: extract_names cs

let list_children node =
    extract_names node.children

let rec insert_child default_data node path data =
    match path with
    | [] -> raise Empty_path
    | [name] -> insert_immediate_child node name data
    | name :: names ->
        let next_child = find_child node name in
        match next_child with
        | Some next_child' ->
            let new_node = insert_child default_data next_child' names data in
            if names = [] then raise Duplicate_child
            else replace_child node new_node
        | None ->
            let next_child' = make name default_data in
            let new_node = insert_child default_data next_child' names data in
            adopt_child node new_node
