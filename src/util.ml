(* Unavoidable module for functions that don't fit anywhere else *)

let find_xml_child name xml =
    let find_aux e =
        match e with
        | Xml.Element (name', _, _) when name' = name -> true
        | _ -> false
    in
    match xml with
    | Xml.Element (_, _, children) -> List.find find_aux children
    | Xml.PCData _ -> raise Not_found
