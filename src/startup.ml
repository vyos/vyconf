(** Various "housekeeping" functions *)

(** Log msg as fatal and exit immediately *)
let panic msg =
    Lwt_log.fatal msg |> Lwt.ignore_result;
    exit 1

let log_info msg = Lwt_log.info msg |> Lwt.ignore_result; ()


(** Setup the default logger *)
let setup_logger daemonize log_file template =
    (** 
       If log file is specified, log to the file whether we are a daemon or not
       If we are a daemon and log file is not specified, log to syslog
       If we are not a daemon and log file is not specified, log to stderr
     *)
    match log_file with
    | None ->
        if daemonize then
            begin
                Lwt_log.default := Lwt_log.syslog ~template:template ~facility:`Daemon ();
                Lwt.return_unit
            end
        else 
            begin
                Lwt_log.default := Lwt_log.channel ~template:template ~close_mode:`Keep ~channel:Lwt_io.stderr ();
                Lwt.return_unit
            end
    | Some file ->
        let%lwt l = Lwt_log.file ~template:template ~mode:`Append ~file_name:file () in
        Lwt_log.default := l; Lwt.return_unit

(** Load the config file or panic if it fails *)
let load_daemon_config path =
    let result = Vyconfd_config.Vyconf_config.load path in
    match result with
    | Ok cfg -> cfg
    | Error err ->
        panic (Printf.sprintf "Could not load the configuration file %s" err)

(** Check if appliance directories exist and panic if they don't *)
let check_dirs dirs =
    let res = Vyconfd_config.Directories.test dirs in
    match res with
    | Ok _ -> ()
    | Error err -> panic err

let delete_socket_if_exists sockfile =
    try
        let _ = Unix.stat sockfile in
        Unix.unlink sockfile
    with
    | Unix.Unix_error (Unix.ENOENT, _, _) -> ()
    | _ -> panic "Could not delete old socket file, exiting"

(** Bind to a UNIX socket *)
let create_socket sockfile =
    let open Lwt_unix in
    let () = delete_socket_if_exists sockfile in
    let backlog = 10 in
    let%lwt sock = socket PF_UNIX SOCK_STREAM 0 |> Lwt.return in
    let%lwt () = Lwt_unix.bind sock @@ ADDR_UNIX(sockfile) in
    listen sock backlog;
    Lwt.return sock

(** Create the server loop function *)
let create_server accept_connection sock =
    let open Lwt in
    let rec serve () =
        Lwt_unix.accept sock >>= accept_connection >>= serve
    in serve

(** Load the appliance configuration file *)
let load_config file =
    try
        let chan = open_in file in
        let s = really_input_string chan (in_channel_length chan) in
        let config = Vyos1x.Parser.from_string s in
        Ok config
    with
        | Sys_error msg -> Error msg
        | Vyos1x.Util.Syntax_error (opt, msg) ->
            begin
                match opt with
                | None ->
                    let out = Printf.sprintf "Parse error: %s\n" msg
                    in Error out
                | Some (line, pos) ->
                    let out = Printf.sprintf "Parse error: %s line %d pos %d\n" msg line pos
                    in Error out
            end

(** Load the appliance configuration file or the fallback config *)
let load_config_failsafe main fallback =
    let res = load_config main in
    match res with
    | Ok config -> config
    | Error msg -> 
        Lwt_log.error
          (Printf.sprintf "Failed to load config file %s: %s. Attempting to load fallback config %s" main msg fallback) |>
          Lwt.ignore_result;
        let res = load_config fallback in
        begin
            match res with
            | Ok config -> config
            | Error msg -> panic (Printf.sprintf "Failed to load fallback config %s: %s, exiting" fallback msg)
        end

(* Load interface definitions from a directory into a reference tree *)
let load_interface_definitions dir =
    let open Vyos1x.Reference_tree in
    let relative_paths = FileUtil.ls dir in
    let absolute_paths =
        try Ok (List.map Vyos1x.Util.absolute_path relative_paths)
        with Sys_error no_dir_msg -> Error no_dir_msg
    in
    let load_aux tree file =
        log_info @@ Printf.sprintf "Loading interface definitions from %s" file;
        load_from_xml tree file
    in
    try begin match absolute_paths with
        | Ok paths  -> Ok (List.fold_left load_aux default paths)
        | Error msg -> Error msg end
    with Bad_interface_definition msg -> Error msg

module I = Vyos1x.Internal.Make(Vyos1x.Reference_tree)

let read_reference_tree file =
    try
        let reftree = I.read_internal file in
        Ok reftree
    with Sys_error msg -> Error msg
