open Vyconfd_client.Vyconf_client
open Vyconf_connect.Vyconf_pbt

type op_t =
    | OpSet
    | OpDelete
    | OpDiscard
    | OpCopy
    | OpRename

let op_of_string s =
    match s with
    | "vy_set" -> OpSet
    | "vy_delete" -> OpDelete
    | "vy_discard" -> OpDiscard
    | "vy_copy" -> OpCopy
    | "vy_rename" -> OpRename
    | _ -> failwith (Printf.sprintf "Unknown operation %s" s)

let config_format_of_string s =
    match s with
    | "curly" -> Curly
    | "json" -> Json
    | _ -> failwith (Printf.sprintf "Unknown config format %s, should be curly or json" s)

let output_format_of_string s =
    match s with
    | "plain" -> Out_plain
    | "json" ->	Out_json
    | _	-> failwith (Printf.sprintf "Unknown output format %s, should be plain or json" s)

let in_cli_config_session () =
    let env = Unix.environment () in
    let res = Array.find_opt (fun c -> String.starts_with ~prefix:"_OFR_CONFIGURE" c) env
    in
    match res with
    | Some _ -> true
    | None -> false

let get_session () =
    let pid =
        try (* set for config session *)
            Int32.of_string (Sys.getenv "SESSION_PID")
        with Not_found ->
            Int32.of_int (Unix.getppid())
    in
    let user =
        try Sys.getenv "USER"
        with Not_found -> ""
    in
    let sudo_user =
        try Sys.getenv "SUDO_USER"
        with Not_found -> ""
    in
    let socket = "/var/run/vyconfd.sock" in
    let config_format = config_format_of_string "curly" in
    let out_format = output_format_of_string "plain" in
    let%lwt client =
        create socket out_format config_format
    in
    let%lwt resp = session_of_pid client pid in
    match resp with
    | Error _ -> setup_session client "vyconf_cli" sudo_user user pid
    | _ as c -> c |> Lwt.return

let close_session () =
    let%lwt client = get_session () in
    match client with
    | Ok c ->
        teardown_session c
    | Error e -> Error e |> Lwt.return

let main op path =
    let%lwt client = get_session () in
    let%lwt result =
    match client with
    | Ok c ->
        begin
        match op with
        | OpSet -> set c path
        | OpDelete -> delete c path
        | OpDiscard -> discard c
        | OpCopy -> copy c path
        | OpRename -> rename c path
        end
    | Error e -> Error e |> Lwt.return
    in
    let () =
        if not (in_cli_config_session ()) then
            close_session () |> Lwt.ignore_result
    in
    match result with
    | Ok s ->
        begin
        match s with
        | "" -> Lwt.return 0
        | _ ->
        let%lwt () =
            Lwt_io.write Lwt_io.stdout (Printf.sprintf "%s\n" s) in Lwt.return 0
        end
    | Error e ->
        begin
        match e with
        | "" -> Lwt.return 1
        | _ ->
        let%lwt () =
            Lwt_io.write Lwt_io.stderr (Printf.sprintf "%s\n" e) in Lwt.return 1
        end

let () =
    let path_list = Array.to_list (Array.sub Sys.argv 1 (Array.length Sys.argv - 1))
    in
    let op_str = FilePath.basename Sys.argv.(0) in
    let op = op_of_string op_str in
    match op, path_list with
    | OpSet, [] | OpDelete, [] ->
        let () = print_endline "Must specify config path" in exit 1
    | OpCopy, [] | OpRename, [] ->
        let () = print_endline "Copy and rename operations require configuration paths" in exit 1
    | _, _ ->
        let result = Lwt_main.run (main op path_list) in exit result
