let valid = ref false

let format_out l =
    let fl = List.filter (fun s -> (String.length s) > 0) l in
    String.concat "\n\n" fl

let is_valid v =
    match v with
    | None -> true
    | Some _ -> false

let valid_err v =
    Option.value v ~default:""

let () =
    let path_list = Array.to_list (Array.sub Sys.argv 1 (Array.length Sys.argv - 1))
    in
    let () =
        if List.length path_list = 0 then
            (Printf.printf "no path specified\n"; exit 1)
    in
    let legacy =
        try
            let _ = Sys.getenv "LEGACY_VALIDATE" in
            true
        with Not_found -> false
    in
    let no_set =
        try
            let _ = Sys.getenv "LEGACY_NO_SET" in
            true
        with Not_found -> false
    in
    let handle =
        if legacy || not no_set then
            let h = Vyos1x_adapter.cstore_handle_init () in
            if not (Vyos1x_adapter.cstore_in_config_session_handle h) then
                (Vyos1x_adapter.cstore_handle_free h;
                Printf.printf "not in config session\n"; exit 1)
            else Some h
        else None
    in
    let valid =
        if not legacy then
            Vyos1x_adapter.vyconf_validate_path path_list
        else
            begin
            let out =
                match handle with
                | Some h -> Vyos1x_adapter.legacy_validate_path h path_list
                | None -> "missing session handle"
            in
            match out with
            | "" -> None
            | _ -> Some out
            end
    in
    let res =
        if not no_set && (is_valid valid) then
            match handle with
            | Some h ->
                Vyos1x_adapter.cstore_set_path h path_list
            | None -> "missing session handle"
        else ""
    in
    let ret =
        if (is_valid valid) && (res = "") then 0
        else 1
    in
    let output = format_out [(valid_err valid); res] in
    let () =
        match handle with
        | Some h -> Vyos1x_adapter.cstore_handle_free h
        | None -> ()
    in
    let () = print_endline output in
    exit ret
