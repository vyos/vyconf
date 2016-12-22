open Lwt
open Defaults
open Vyconf_config

let () = Lwt_log.add_rule "*" Lwt_log.Info

(* Default VyConf configuration *)
let daemonize = ref true
let config_file = ref defaults.config_file
let log_file = ref None

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

let main_loop config () =
    let%lwt () = Startup.setup_logger !daemonize !log_file config.log_template in
    let%lwt () = Lwt_log.notice @@ Printf.sprintf "Starting VyConf for %s" config.app_name in
    Lwt.return_unit

let () = 
  let () = Arg.parse args (fun f -> ()) usage in
  let config = Startup.load_config !config_file in
  let () = Lwt_log.load_rules ("* -> " ^ config.log_level) in
  let dirs = Directories.make config in
  Startup.check_dirs dirs;
  Lwt_main.run @@ main_loop config ()
  
