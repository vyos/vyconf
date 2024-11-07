open Client.Vyconf_client_session

let path_opt = ref ""

let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let args = [
    ("--path", Arg.String (fun s -> path_opt := s), "<string> Configuration path");
   ]

let get_sockname =
    "/var/run/vyconfd.sock"

let main socket path_list =
    let token = session_init socket in
    match token with
    | Error e -> "Failed to initialize session: " ^ e
    | Ok token ->
        let out = session_validate_path socket token path_list
        in
        let _ = session_free socket token in
        match out with
        | Error e -> "Failed to validate path: " ^ e
        | Ok _ -> "No error"

let _ =
    let () = Arg.parse args (fun _ -> ()) usage in
    let path_list = Vyos1x.Util.list_of_path !path_opt in
    let socket = get_sockname in
    let result = main socket path_list in
    let () = print_endline result in
    exit 0
