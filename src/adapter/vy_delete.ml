let path_opt = ref []

let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let read_path p =
    path_opt := p::!path_opt

let speclist = [
   ]

let () =
    let () = Arg.parse speclist read_path usage in
    let path_list = List.rev !path_opt in
    let () =
        if List.length path_list = 0 then
            (Printf.printf "no path specified\n"; exit 1)
    in
    let handle =
        let h = Vyos1x_adapter.cstore_handle_init () in
        if not (Vyos1x_adapter.cstore_in_config_session_handle h) then
            (Vyos1x_adapter.cstore_handle_free h;
            Printf.printf "not in config session\n"; exit 1)
        else Some h
    in
    let output =
        match handle with
        | Some h -> Vyos1x_adapter.cstore_delete_path h path_list
        | None -> "missing session handle"
    in
    let ret =
        if output = "" then 0
        else 1
    in
    let () =
        match handle with
        | Some h -> Vyos1x_adapter.cstore_handle_free h
        | None -> ()
    in
    let () = print_endline output in
    exit ret
