type node_type = Leaf | Tag | Other

type ref_node_data = {
    node_type: node_type;
    constraints: (Value_checker.value_constraint list);
    help: string;
    value_help: (string * string) list;
    constraint_error_message: string;
    multi: bool;
    valueless: bool;
    owner: string option;
    keep_order: bool;
    hidden: bool;
    secret: bool;
}

type t = ref_node_data Vytree.t

exception Bad_interface_definition of string

exception Validation_error of string

let default_data = {
    node_type = Other;
    constraints = [];
    help = "No help available";
    value_help = [];
    constraint_error_message = "Invalid value";
    multi = false;
    valueless = false;
    owner = None;
    keep_order = false;
    hidden = false;
    secret = false;
}

let default = Vytree.make default_data "root"

(* Loading from XML *)

let node_type_of_string s =
    match s with
    | "node" -> Other
    | "tagNode" -> Tag
    | "leafNode" -> Leaf
    | _ -> raise (Bad_interface_definition
                  (Printf.sprintf "node, tagNode, or leafNode expected, %s found" s))

let load_constraint_from_xml d c =
    let aux d c = 
        match c with
        | Xml.Element ("regex", _, [Xml.PCData s]) ->
            let cs = (Value_checker.Regex s) :: d.constraints in
            {d with constraints=cs}
        | Xml.Element ("validator", [("name", n); ("argument", a)], _) ->
            let cs = (Value_checker.External (n, Some a)) :: d.constraints in
            {d with constraints=cs}
        | Xml.Element ("validator", [("name", n)], _) ->
            let cs = (Value_checker.External (n, None)) :: d.constraints in
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
        | Xml.Element ("hidden", _, _) -> {d with hidden=true}
        | Xml.Element ("secret", _, _) -> {d with secret=true}
        | Xml.Element ("keepChildOrder", _, _) -> {d with keep_order=true}
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
        let data = {data with node_type=node_type; owner=node_owner} in
        let name = Xml.attrib xml "name" in
        let path = basepath @ [name] in
        let new_tree = Vytree.insert reftree path data in
        (match node_type with
        | Leaf -> new_tree
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
            List.fold_left (insert_from_xml []) reftree children
        | _ -> raise (Bad_interface_definition "Should start with <interfaceDefinition>")
    in
    try
        let xml = Xml.parse_file file in
        xml_to_reftree xml reftree
    with
    | Xml.File_not_found msg -> raise (Bad_interface_definition msg)
    | Xml.Error e -> raise (Bad_interface_definition (Xml.error e))

let load_interface_definitions dir =
    let relative_paths =
        try
            FileUtil.ls dir
        with Sys_error no_dir_msg -> Startup.panic no_dir_msg
    in
    let absolute_paths = List.map Util.absolute_path relative_paths in
    try
        List.fold_left load_from_xml default absolute_paths
    with Bad_interface_definition msg -> Startup.panic msg

(* Validation function *)

let has_illegal_characters name =
    (** Checks if string name has illegal characters in it.
        All whitespace, curly braces, square brackets, and quotes
        are disallowed due to their special significance to the curly config
        format parser *)
    try Some (Pcre.get_substring (Pcre.exec ~pat:"[\\s\\{\\}\\[\\]\"\'#]" name) 0)
    with Not_found -> None

(** Takes a list of string that represents a configuration path that may have
    node value at the end, validates it, and splits it into path and value parts.

   A list of strings is a valid path that can be created in the config tree unless:
     1. It's a tag node without a child
     2. It's a non-valueless leaf node without a value
     3. It's a valueless node with a value
     4. It's a non-valueless leaf node with garbage after the value
     5. It's a non-leaf, non-tag node with a name that doesn't exist
        in the reference tree
 *)
let rec validate_path validators_dir node path =
    let show_path p = Printf.sprintf "[%s]" @@ Util.string_of_path (List.rev p) in
    let rec aux node path acc =
        let data = Vytree.data_of_node node in
        match data.node_type with
        | Leaf ->
            (match path with
             | [] ->
                 if data.valueless then (List.rev acc, None)
                 else raise (Validation_error
                   (Printf.sprintf "Node %s requires a value" (show_path acc) ))
             | [p] ->
                 if not data.valueless then
                     (if (Value_checker.validate_any validators_dir data.constraints p) then (List.rev acc, Some p)
                     else raise (Validation_error data.constraint_error_message))
                 else raise (Validation_error
                   (Printf.sprintf "Node %s cannot have a value" (show_path acc)))
             | p :: ps -> raise (Validation_error (Printf.sprintf "Path %s is too long" (show_path acc))))
        | Tag ->
            (match path with
             | p :: p' :: ps ->
                 (match (has_illegal_characters p) with
                 | Some c -> raise (Validation_error (Printf.sprintf "Illegal character \"%s\" in node name \"%s\"" c p))
                 | None ->
                     if (Value_checker.validate_any validators_dir data.constraints p) then
                         let child = Vytree.find node p' in
                         (match child with
                          | Some c -> aux c ps (p' :: p :: acc)
                          | None -> raise (Validation_error (Printf.sprintf "Node %s has no child %s" (show_path acc) p')))
                     else raise (Validation_error (Printf.sprintf "%s is not a valid child name for node %s" p (show_path acc))))
             | [p] -> if (Value_checker.validate_any validators_dir data.constraints p) then (List.rev acc, None)
                          else raise (Validation_error (Printf.sprintf "Node %s has no child %s" (show_path acc) p))
             | _ -> raise (Validation_error (Printf.sprintf "Path %s is incomplete" (show_path acc))))
        | Other ->
            (match path with
             | [] -> (List.rev acc, None)
             | p :: ps ->
                 let child = Vytree.find node p in
                 (match child with
                  | Some c -> aux c ps (p :: acc)
                  | None -> raise (Validation_error ((Printf.sprintf "Path %s is incomplete" (show_path acc))))))
    in aux node path []

let is_multi reftree path =
    let data = Vytree.get_data reftree path in
    data.multi

let is_hidden reftree path =
    let data = Vytree.get_data reftree path in
    data.hidden

let is_secret reftree path =
    let data = Vytree.get_data reftree path in
    data.secret

let is_tag reftree path =
    let data = Vytree.get_data reftree path in
    match data.node_type with
    | Tag -> true
    | _ -> false

let is_leaf reftree path = 
    let data = Vytree.get_data reftree path in
    match data.node_type with
    | Leaf -> true
    | _ -> false

let is_valueless reftree path =
    let data = Vytree.get_data reftree path in
    data.valueless

let get_keep_order reftree path =
    let data = Vytree.get_data reftree path in
    data.keep_order

let get_owner reftree path =
    let data = Vytree.get_data reftree path in
    data.owner

let get_help_string reftree path =
    let data = Vytree.get_data reftree path in
    data.help

let get_value_help reftree path =
    let data = Vytree.get_data reftree path in
    data.value_help

let get_completion_data reftree path =
    let aux node =
        let data = Vytree.data_of_node node in
        (data.node_type, data.multi, data.help)
    in List.map aux (Vytree.children_of_node @@ Vytree.get reftree path)
