type value_behaviour = AddValue | ReplaceValue

exception Duplicate_value
exception Node_has_no_value
exception No_such_value
exception Useless_set

type config_node_data = {
    values: string list;
    comment: string option;
    inactive: bool;
    ephemeral: bool;
} [@@deriving yojson]

type t = config_node_data Vytree.t [@@deriving yojson]

let default_data = {
    values = [];
    comment = None;
    inactive = false;
    ephemeral = false;
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

let set_inactive node path inactive =
    let data = Vytree.get_data node path in
    Vytree.update node path {data with inactive=inactive}

let is_inactive node path =
    let data = Vytree.get_data node path in
    data.inactive

let set_ephemeral node path ephemeral =
    let data = Vytree.get_data node path in
    Vytree.update node path {data with ephemeral=ephemeral}

let is_ephemeral node path =
    let data = Vytree.get_data node path in
    data.ephemeral

(* TODO Reference tree version *)
let render
        ?(indent=4)
        ?reftree
        ?(cmp=BatString.numeric_compare)
        ?(showephemeral=false)
        ?(showinactive=false)
        (config_tree:t)
    =
    let is_hidden_node data =
        (not showephemeral && data.ephemeral) ||
        (not showinactive && data.inactive)
    in
    let render_values = function
        | [v] -> Printf.sprintf "%s;" v
        | vs  -> String.concat "; " vs |> Printf.sprintf "[%s];"
    in
    let render_inactive data =
        if data.inactive
        then Some "#INACTIVE"
        else None
    in
    let render_ephemeral data =
        if data.ephemeral
        then Some "#EPHEMERAL"
        else None
    in
    let render_comment = function
        | None   -> None
        | Some c -> Some (Printf.sprintf "/*%s*/ " c)
    in
    let render_outer outer =
        let rec filter = function
            | [] -> []
            | Some x :: rest -> x :: filter rest
            | None   :: rest -> filter rest
        in
        String.concat " " (filter outer)
    in
    let rec render_node level node =
        let data = Vytree.data_of_node node in
        (* Hide inactive and ephemeral when necessary *)
        if  is_hidden_node data
        then ""
        else
            let indents  = String.make (level * indent) ' ' in
            let name     = Vytree.name_of_node node in
            let children = Vytree.children_of_node node in
            let outer = render_outer [render_inactive data;
                                      render_ephemeral data;
                                      render_comment data.comment;
                                      Some name]
            in
            (* Children are ignored if the node has values. *)
            let inner = match data.values with
                | []     -> render_children (level + 1) children
                | values -> render_values values
            in
            match inner with
            | "" -> Printf.sprintf "%s%s { }" indents outer  (* Hidden or empty descendents *)
            | _  -> Printf.sprintf "%s%s {\n%s\n%s}" indents outer inner indents
    and render_children level = function
        | []       -> ""
        | children -> List.map (render_node level) children
                      |> String.concat "\n"
    in
    match reftree with
    | None    -> render_node 0 config_tree
    | Some rt -> raise No_such_value (* render_node_rt 0 config_tree *)
