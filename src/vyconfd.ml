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

let rec handle_connection ic oc () =
    let open Vyconf_pb in
    try%lwt
        let%lwt req_msg = Message.read ic in
        let%lwt req = decode_request (Pbrt.Decoder.of_bytes req_msg) |> return in
        let%lwt resp =
            (match req with
            | Status -> {status=Success; output=None; error=None; warning=(Some "None of the other functions are implemented though")}
            | _ -> failwith "Unimplemented") |> return
        in
        let enc = Pbrt.Encoder.create () in
        let%lwt () = encode_response resp enc |> return in
        let%lwt resp_msg = Pbrt.Encoder.to_bytes enc |> return in
        let%lwt () = Message.write oc resp_msg in
        handle_connection ic oc ()
    with
    | Failure e -> Lwt_log.error e >>= handle_connection ic oc
    | End_of_file -> Lwt_log.info "Connection closed" >>= return

let accept_connection conn =
    let fd, _ = conn in
    let ic = Lwt_io.of_fd Lwt_io.Input fd in
    let oc = Lwt_io.of_fd Lwt_io.Output fd in
    Lwt.on_failure (handle_connection ic oc ()) (fun e -> Lwt_log.ign_error (Printexc.to_string e));
    Lwt_log.info "New connection" >>= return

let main_loop config () =
    let%lwt () = Startup.setup_logger !daemonize !log_file config.log_template in
    let%lwt () = Lwt_log.notice @@ Printf.sprintf "Starting VyConf for %s" config.app_name in
    let%lwt sock = Startup.create_socket config.socket in
    let%lwt serve = Startup.create_server accept_connection sock () in
    serve ()

let () = 
  let () = Arg.parse args (fun f -> ()) usage in
  let config = Startup.load_config !config_file in
  let () = Lwt_log.load_rules ("* -> " ^ config.log_level) in
  let dirs = Directories.make config in
  Startup.check_dirs dirs;
  Lwt_main.run @@ main_loop config ()
  
