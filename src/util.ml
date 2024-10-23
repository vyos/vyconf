(** The unavoidable module for functions that don't fit anywhere else *)

(** Find a child node in xml-lite *)
let find_xml_child name xml =
    let find_aux e =
        match e with
        | Xml.Element (name', _, _) when name' = name -> true
        | _ -> false
    in
    match xml with
    | Xml.Element (_, _, children) -> Vyos1x.Vylist.find find_aux children
    | Xml.PCData _ -> None

(** Convert a list of strings to a string of unquoted, space separated words *)
let string_of_list ss =
    let rec aux xs acc =
        match xs with
        | [] -> acc
        | x :: xs' -> aux xs' (Printf.sprintf "%s %s" acc x)
    in
    match ss with
    | [] -> ""
    | x :: xs -> Printf.sprintf "%s%s" x (aux xs "")

(** Convert a list of strings to JSON *)
let json_of_list ss =
    let ss = List.map (fun x -> `String x) ss in
    Yojson.Safe.to_string (`List ss)

(** Convert a relative path to an absolute path based on the current working directory *)
let absolute_path relative_path =
    FilePath.make_absolute (Sys.getcwd ()) relative_path

(** Makes a hex dump of a byte string *)
let hexdump b =
    let dump = ref "" in
    Bytes.iter (fun c -> dump := Char.code c |> Printf.sprintf "%s %02x" !dump) b;
    !dump
