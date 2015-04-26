exception Duplicate_value

type config_node_data = {
    values: string list;
    comment: string;
    node_type: Vytree.node_type;
}

type t = config_node_data Vytree.t

let default_data = {
    values = [];
    comment = "";
    node_type = Vytree.Other;
}

let make = Vytree.make default_data

let set_value node path value =
    let data = { default_data with values=[value] } in
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

let get_values node path =
    let node' = Vytree.get node path in
    let data = Vytree.data_of_node node' in
    data.values
