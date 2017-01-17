(* Unavoidable module for functions that don't fit anywhere else *)

let find_xml_child name xml =
    let find_aux e =
        match e with
        | Xml.Element (name', _, _) when name' = name -> true
        | _ -> false
    in
    match xml with
    | Xml.Element (_, _, children) -> Vylist.find find_aux children
    | Xml.PCData _ -> None

(* Dirty pretty printer *)
let string_of_path path =
    let rec aux xs acc =
        match xs with
        | [] -> acc
        | x :: xs' -> aux xs' (Printf.sprintf "%s %s" acc x)
    in
    match path with
    | [] -> ""
    | x :: xs -> Printf.sprintf "%s%s" x (aux xs "")

let substitute_default o d =
    match o with
    | None -> d
    | Some v -> v

let absolute_path relative_path =
    FilePath.make_absolute (Sys.getcwd ()) relative_path
