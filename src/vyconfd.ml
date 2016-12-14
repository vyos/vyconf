open Lwt
open Defaults
open Vyconf_config

let () = Lwt_log.add_rule "*" Lwt_log.Info

(* Default VyConf configuration *)
let daemonize = ref true
let config_file = ref defaults.config_file
let log_file = ref None
let log_template = ref "$(date): $(message)"

(* Global data *)

(* Command line arguments *)
let args = [
    ("--no-daemon", Arg.Unit (fun () -> daemonize := false),
         "Do not daemonize");
        ("--config", Arg.String (fun s -> config_file := s),
         (Printf.sprintf "<string>    Configuration file, default is %s" defaults.config_file));
        ("--log-file", Arg.String (fun s -> log_file := Some s),
        "<string>    Log file");
        ("--version", Arg.Unit (fun () -> print_endline @@ Version.version_info (); exit 0), "Print version and exit")
    ]
let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let load_config path =
    let result = Vyconf_config.load path in
    match result with
    | Ok cfg -> cfg
    | Error err ->
        Lwt_log.fatal (Printf.sprintf "Could not load the configuration file %s" err) |> Lwt.ignore_result;
        exit 1

let setup_logger daemonize log_file template =
    (* 
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

let main_loop config () =
    let%lwt () = setup_logger !daemonize !log_file !log_template in
    let%lwt () = Lwt_log.notice @@ Printf.sprintf "Loading %s" config.app_name in
    Lwt.return_unit

let () = 
  let () = Arg.parse args (fun f -> ()) usage in
  let config = load_config !config_file in
  Lwt_main.run @@ main_loop config ()
  
