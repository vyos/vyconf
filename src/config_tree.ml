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

module Renderer =
struct
    (* TODO Replace use of Printf with Format *)

    module L  = List
    module S  = String
    module PF = Printf
    module VT = Vytree
    module RT = Reference_tree

    (* Nodes are ordered based on a comarison of their names *)
    let compare cmp node1 node2 =
        let name1 = VT.name_of_node node1 in
        let name2 = VT.name_of_node node2 in
        cmp name1 name2

    let indentation indent level = S.make (level * indent) ' '

    let render_inactive data  = if data.inactive  then "#INACTIVE "  else ""
    let render_ephemeral data = if data.ephemeral then "#EPHEMERAL " else ""

    let render_comment data indents =
        match data.comment with
        | None   -> ""
        (* Trailing indentation for the rest of the material on the next line *)
        | Some c -> PF.sprintf "/*%s*/\n%s" c indents

    let render_tag = function
        | None     -> ""
        | Some tag -> PF.sprintf "%s " tag

    let render_outer indents data name tag =
        [render_comment data indents ;
         render_inactive data;
         render_ephemeral data;
         render_tag tag;
         name]
        |> S.concat ""

    let render_values ?(valueless=false) values =
        let quote_if_needed s =
            try
                let _ = Pcre.exec ~pat:"[\\s;{}#\\[\\]\"\']" s in
                Printf.sprintf "\"%s\"" s
             with Not_found -> s
        in
        match values with
        | [] -> if valueless then ";" else "{ }"
        | [v] -> PF.sprintf "%s;" (quote_if_needed v)
        | _ as vs  -> S.concat "; " (List.map quote_if_needed vs) |> PF.sprintf "[%s];"

    let render_inner_and_outer indents inner outer =
        if inner = ""
        (* Hidden or empty descendents yield empty nodes *)
        then PF.sprintf "%s%s { }" indents outer
        else PF.sprintf "%s%s %s" indents outer inner

    let render
            ?(indent=4)
            ?(reftree=None)
            ?(cmp=BatString.numeric_compare)
            ?(showephemeral=false)
            ?(showinactive=false)
            (config_tree:t)
        =
        let is_hidden data =
            (not showephemeral && data.ephemeral) ||
            (not showinactive && data.inactive)
        in
        let rec render_node level ?tag node =
            let data = VT.data_of_node node in
            let name = VT.name_of_node node in
            (* Hide inactive and ephemeral when necessary *)
            if is_hidden data then ""
            else
                let indents = indentation indent level in
                let outer = render_outer indents data name tag in
                let inner = (* Children are ignored if the node has values *)
                    match data.values with
                    | [] -> VT.children_of_node node |> render_children level
                    | values -> render_values values
                in
                PF.sprintf "%s%s %s" indents outer inner
        and render_children level = function
            | [] -> "{ }"
            | children ->
            let indents = indentation indent level in
            let render_child node = render_node (level + 1) node in
            let rendered_children = L.map render_child children |> S.concat "\n"
            in
            if rendered_children = "" then "{ }"
            else PF.sprintf "{\n%s\n%s}" rendered_children indents
        in
        (* Walks the reftree and config_tree side-by-side *)
        let rec render_node_rt level tag rt node =
            let data    = VT.data_of_node node in
            let name    = VT.name_of_node node in
            let rt_data = VT.data_of_node rt in
            let rt_name = VT.name_of_node rt in
            (* Hide inactive and ephemeral when necessary *)
            if is_hidden data  then ""
            else
                (* TODO refactor this ugly approach*)
                let (outer_name, level', inner) =
                    let open RT in
                    let children = VT.children_of_node node in
                    let ordered = rt_data.keep_order in
                    match rt_data.node_type with
                    | Tag   ->
                        ("", 0, render_children_rt level (Some name) ordered rt children)
                    | Other ->
                        (name, level, render_children_rt level None ordered rt children)
                    | Leaf  ->
                        (name, level, render_values ~valueless:rt_data.valueless data.values)
                in
                let indents = indentation indent level' in
                let outer = render_outer indents data outer_name tag in
                (* Do not insert a space before ; for valueless nodes *)
                if rt_data.valueless then PF.sprintf "%s%s%s" indents outer inner
                else PF.sprintf "%s%s %s" indents outer inner
        and render_children_rt level tag ordered rt = function
            | [] -> "{ }"
            | children ->
                let is_tagged = BatOption.is_some tag in
                let indents = indentation indent level in
                let reorder nodes =
                    if ordered then nodes
                    else L.sort (compare cmp) nodes
                in
                let render_child node =
                    let level' = if is_tagged then level else level + 1 in
                    let node_reftree = VT.find rt (VT.name_of_node node) in
                    (* If there is no reftree for a node, default to stand-alone *)
                    match node_reftree with
                    | Some rt' -> render_node_rt level' tag rt' node
                    | None     -> render_node level' ?tag node
                in
                let rendered_children = children
                                        |> reorder
                                        |> L.map render_child
                                        |> S.concat "\n"
                in
                if rendered_children = "" then "{ }"
                else if is_tagged
                then rendered_children
                else PF.sprintf "{\n%s\n%s}" rendered_children indents
        in
        match reftree with
        | None    -> render_node 0 config_tree
        | Some rt -> render_node_rt 0 None rt config_tree

end (* Renderer *)

let render = Renderer.render

let render_at_level
  ?(indent=4)
  ?(reftree=None)
  ?(cmp=BatString.numeric_compare)
  ?(showephemeral=false)
  ?(showinactive=false)
  node
  path =
    let node = 
        match path with
        | [] -> node
        | _ -> Vytree.get node path
    in
    let children = Vytree.children_of_node node in
    let child_configs = List.map (render ~indent:indent ~reftree:reftree  ~cmp:cmp ~showephemeral:showephemeral ~showinactive:showinactive) children in
    List.fold_left (Printf.sprintf "%s\n%s") "" child_configs
