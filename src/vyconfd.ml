open Lwt
open Defaults
open Vyconf_config
open Vyconf_pb

(* On UNIX, self_init uses /dev/random for seed *)
let () = Random.self_init ()

let () = Lwt_log.add_rule "*" Lwt_log.Info

(* Default VyConf configuration *)
let daemonize = ref true
let config_file = ref defaults.config_file
let log_file = ref None

(* Global data *)
let sessions : (string, Session.session_data) Hashtbl.t = Hashtbl.create 10

let commit_lock : string option ref = ref None

let conf_mode_lock : string option ref = ref None

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

let response_tmpl = {status=Success; output=None; error=None; warning=None}

let make_session_token () =
    Sha1.string (string_of_int (Random.bits ())) |> Sha1.to_hex

let setup_session world req =
    let token = make_session_token () in
    let user = "unknown user" in
    let client_app = Util.substitute_default req.client_application "unknown client" in
    let () = Hashtbl.add sessions token (Session.make world client_app user) in
    {response_tmpl with output=(Some token)}

let enter_conf_mode req token =
    let open Session in
    let aux token session =
        let open Session in
        let session = {session with conf_mode=true} in
        Hashtbl.replace sessions token session;
        response_tmpl 
    in
    let lock = !conf_mode_lock in
    let session = Hashtbl.find sessions token in
    match lock with
    | Some user ->
        if req.override_exclusive then aux token session
        else
        {response_tmpl with
           status=Configuration_locked;
           error=Some (Printf.sprintf "Configuration was locked by %s" user)}
    | None ->
        if req.exclusive then (conf_mode_lock := Some session.user; aux token session)
        else aux token session

let exit_conf_mode world token =
    let open Session in
    let session = Hashtbl.find sessions token in
    let session = {session with
        proposed_config=world.running_config;
        changeset = [];
        modified = false}
    in Hashtbl.replace sessions token session;
    response_tmpl

let teardown_session token =
    try
        Hashtbl.remove sessions token;
        response_tmpl
    with Not_found ->
        {response_tmpl with status=Fail; error=(Some "Session not found")}

let rec handle_connection world ic oc () =
    let open Vyconf_pb in
    try%lwt
        let%lwt req_msg = Message.read ic in
        let%lwt req =
            let envelope = decode_request_envelope (Pbrt.Decoder.of_bytes req_msg) in
            Lwt.return (envelope.token, envelope.request)
        in
        let%lwt resp =
            (match req with
            | _, Status -> response_tmpl
            | _, Setup_session r -> setup_session world r
            | None, _ -> {response_tmpl with status=Fail; output=(Some "Operation requires session token")}
            | Some t, Teardown _ -> teardown_session t
            | Some t, Configure r -> enter_conf_mode r t
            | Some t, Exit_configure -> exit_conf_mode world t
            | _ -> failwith "Unimplemented") |> return
        in
        let enc = Pbrt.Encoder.create () in
        let%lwt () = encode_response resp enc |> return in
        let%lwt resp_msg = Pbrt.Encoder.to_bytes enc |> return in
        let%lwt () = Message.write oc resp_msg in
        handle_connection world ic oc ()
    with
    | Failure e -> Lwt_log.error e >>= handle_connection world ic oc
    | End_of_file -> Lwt_log.info "Connection closed" >>= return

let accept_connection world conn =
    let fd, _ = conn in
    let ic = Lwt_io.of_fd Lwt_io.Input fd in
    let oc = Lwt_io.of_fd Lwt_io.Output fd in
    Lwt.on_failure (handle_connection world ic oc ()) (fun e -> Lwt_log.ign_error (Printexc.to_string e));
    Lwt_log.info "New connection" >>= return

let main_loop world () =
    let open Session in
    let%lwt () = Startup.setup_logger !daemonize !log_file world.vyconf_config.log_template in
    let%lwt () = Lwt_log.notice @@ Printf.sprintf "Starting VyConf for %s" world.vyconf_config.app_name in
    let%lwt sock = Startup.create_socket world.vyconf_config.socket in
    let%lwt serve = Startup.create_server (accept_connection world) sock () in
    serve ()

let load_interface_definitions dir =
    let open Session in
    let reftree = Reference_tree.load_interface_definitions dir in
    match reftree with
    | Ok r -> r
    | Error s -> Startup.panic s

let make_world config dirs =
    let open Directories in
    let open Session in
    let reftree = load_interface_definitions dirs.interface_definitions in
    let running_config = Config_tree.make "root" in
    {running_config=running_config; reference_tree=reftree; vyconf_config=config; dirs=dirs}

let () = 
  let () = Arg.parse args (fun f -> ()) usage in
  let config = Startup.load_config !config_file in
  let () = Lwt_log.load_rules ("* -> " ^ config.log_level) in
  let dirs = Directories.make config in
  Startup.check_dirs dirs;
  let world = make_world config dirs in
  Lwt_main.run @@ main_loop world ()
  
