type 'a vyconf_tree = Node of string * 'a * ('a vyconf_tree list)

exception Empty_path
exception Duplicate_child
exception Nonexistent_path

let name_of_node (Node (name, _, _)) = name

let children_of_node (Node (_, _, children)) = children

let data_of_node (Node (_, data, _)) = data

let destructure_node node =
    name_of_node node,
    data_of_node node,
    children_of_node node

let rec find_child_in_list children name =
    match children with
    | [] -> None
    | c :: cs -> if (name_of_node c) = name then (Some c)
                 else find_child_in_list cs name

let find_child node name =
    find_child_in_list (children_of_node node) name

let rec remove_child_from_list children name =
    match children with
    | [] -> []
    | c :: cs -> if (name_of_node c) = name then cs
                 else c :: (remove_child_from_list cs name)

let extract_child children name =
    find_child_in_list children name,
    remove_child_from_list children name

let insert_immediate_child node name data =
    let new_node = Node (name, data, []) in
    let (old_name, old_data, old_children) = destructure_node node in
    Node (old_name, old_data, new_node :: old_children)

let adopt_child node child =
    let (old_name, old_data, old_children) = destructure_node node in
    Node (old_name, old_data, child :: old_children)

let replace_child node child =
    let (old_name, old_data, old_children) = destructure_node node in
    let child_name = name_of_node child in
    let old_children' = remove_child_from_list old_children child_name in
    Node (old_name, old_data, child :: old_children')

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
            let next_child' = Node (name, default_data, []) in
            let new_node = insert_child default_data next_child' names data in
            adopt_child node new_node
