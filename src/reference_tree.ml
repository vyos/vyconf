type ref_node_data = {
    node_type: Vytree.node_type;
    constraints: (Value_checker.value_constraint list);
    help: string;
    value_help: (string * string) list;
    constraint_error_message: string;
    multi: bool;
    valueless: bool;
    owner: string option;
}

type t = ref_node_data Vytree.t

exception Bad_interface_definition of string

let default_data = {
    node_type = Vytree.Other;
    constraints = [];
    help = "No help available";
    value_help = [];
    constraint_error_message = "Invalid value";
    multi = false;
    valueless = false;
    owner = None;
}

(* Loading from XML *)

let node_type_of_string s =
    match s with
    | "node" -> Vytree.Other
    | "tagNode" -> Vytree.Tag
    | "leafNode" -> Vytree.Leaf
    | _ -> raise (Bad_interface_definition
                  (Printf.sprintf "node, tagNode, or leafNode expected, %s found" s))

let load_constraint_from_xml d c =
    let aux d c = 
        match c with
        | Xml.Element ("regex", _, [Xml.PCData s]) ->
            let cs = (Value_checker.Regex s) :: d.constraints in
            {d with constraints=cs}
        | Xml.Element ("validator", [("name", n); ("argument", a)], _) ->
            let cs = (Value_checker.External (n, a)) :: d.constraints in
            {d with constraints=cs}
        | _ -> raise (Bad_interface_definition "Malformed constraint")
    in Xml.fold aux d c

let data_from_xml d x =
    let aux d x =
        match x with
        | Xml.Element ("help", _, [Xml.PCData s]) -> {d with help=s}
        | Xml.Element ("valueHelp", _,
                       [Xml.Element ("format", _, [Xml.PCData fmt]);
                        Xml.Element ("description", _, [Xml.PCData descr])]) ->
            let vhs = d.value_help in
            let vhs' = (fmt, descr) :: vhs in
            {d with value_help=vhs'}
        | Xml.Element ("multi", _, _) -> {d with multi=true}
        | Xml.Element ("valueless", _, _) -> {d with valueless=true}
        | Xml.Element ("constraintErrorMessage", _, [Xml.PCData s]) ->
            {d with constraint_error_message=s}
        | Xml.Element ("constraint", _, _) -> load_constraint_from_xml d x
        | _ -> raise (Bad_interface_definition "Malformed property tag")
    in Xml.fold aux d x

let rec insert_from_xml basepath reftree xml =
    match xml with
    | Xml.Element (tag, _,  _) ->
        let props = Util.find_xml_child "properties" xml in
        let data =
            (match props with
            | None -> default_data
            | Some p -> data_from_xml default_data p)
        in
        let node_type = node_type_of_string (Xml.tag xml) in
        let node_owner = try let o = Xml.attrib xml "owner" in Some o
                         with _ -> None
        in
        let data = {data with node_type = node_type; owner = node_owner} in
        let name = Xml.attrib xml "name" in
        let path = basepath @ [name] in
        let new_tree = Vytree.insert reftree path data in
        (match node_type with
        | Vytree.Leaf -> new_tree
        | _ ->
            let children = Util.find_xml_child "children" xml in
            (match children with
             | None -> raise (Bad_interface_definition (Printf.sprintf "Node %s has no children" name))
             | Some c ->  List.fold_left (insert_from_xml path) new_tree (Xml.children c)))
    | _ -> raise (Bad_interface_definition "PCData not allowed here") 

let load_from_xml reftree file =
    let xml_to_reftree xml reftree =
        match xml with
        | Xml.Element ("interfaceDefinition", attrs, children) ->
            let basepath =
                try Pcre.split (Xml.attrib xml "extends")
                with _ -> []
            in List.fold_left (insert_from_xml basepath) reftree children
            
            
        | _ -> raise (Bad_interface_definition "Should start with <interfaceDefinition>")
    in
    let xml = Xml.parse_file file in
    xml_to_reftree xml reftree
