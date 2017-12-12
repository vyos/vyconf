(** Various "housekeeping" functions *)

(** Log msg as fatal and exit immediately *)
let panic msg =
    Lwt_log.fatal msg |> Lwt.ignore_result;
    exit 1

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
    let result = Vyconf_config.load path in
    match result with
    | Ok cfg -> cfg
    | Error err ->
        panic (Printf.sprintf "Could not load the configuration file %s" err)

(** Check if appliance directories exist and panic if they don't *)
let check_dirs dirs =
    let res = Directories.test dirs in
    match res with
    | Ok _ -> ()
    | Error err -> panic err

(** Bind to a UNIX socket *)
let create_socket sockfile =
    let open Lwt_unix in
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
