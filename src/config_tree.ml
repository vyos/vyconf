type value_behaviour = AddValue | ReplaceValue

exception Duplicate_value
exception Node_has_no_value
exception No_such_value
exception Useless_set

type config_node_data = {
    values: string list;
    comment: string option;
}

type t = config_node_data Vytree.t

let default_data = {
    values = [];
    comment = None;
}

let make name = Vytree.make default_data name

let replace_value node path value =
    let data = {default_data with values=[value]} in
    Vytree.update node path data

let add_value node path value =
    let node' = Vytree.get node path in
    let data = Vytree.data_of_node node' in
    let values = data.values in
    match (Vylist.find (fun x -> x = value) values) with
    | Some _ -> raise Duplicate_value
    | None ->
        let values = values @ [value] in
        Vytree.update node path ({data with values=values})

let delete_value node path value =
    let data = Vytree.data_of_node @@ Vytree.get node path in
    let values = Vylist.remove (fun x -> x = value) data.values in
    Vytree.update node path {data with values=values}

let set_value node path value behaviour =
    match behaviour with
    | AddValue -> add_value node path value
    | ReplaceValue -> replace_value node path value

let set node path value behaviour =
    if (Vytree.exists node path) then
        (match value with
         | None -> raise Useless_set
         | Some v -> set_value node path v behaviour)
    else
        let path_existing = Vytree.get_existent_path node path in
        let path_remaining = Vylist.complement path path_existing in
        let values = match value with None -> [] | Some v -> [v] in
        Vytree.insert_multi_level default_data node path_existing path_remaining {default_data with values=values}

let get_values node path =
    let node' = Vytree.get node path in
    let data = Vytree.data_of_node node' in
    data.values

let get_value node path =
    let values = get_values node path in
    match values with
    | [] -> raise Node_has_no_value
    | x :: _ -> x

let delete node path value =
    match value with
    | Some v ->
        (let values = get_values node path in
        if Vylist.in_list values v then
        (match values with
        | [_] -> Vytree.delete node path
        | _ -> delete_value node path v)
        else raise No_such_value)
    | None ->
	Vytree.delete node path

let set_comment node path comment =
    let data = Vytree.get_data node path in
    Vytree.update node path {data with comment=comment}

let get_comment node path =
    let data = Vytree.get_data node path in
    data.comment
