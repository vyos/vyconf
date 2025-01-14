open Lwt

open Vyconf_connect.Vyconf_pbt
open Vyconfd_config.Defaults
open Vyconfd_config.Vyconf_config

module FP = FilePath
module CT = Vyos1x.Config_tree
module Gen = Vyos1x.Generate
module Session = Vyconfd_config.Session
module Directories = Vyconfd_config.Directories

(* On UNIX, self_init uses /dev/random for seed *)
let () = Random.self_init ()

let () = Lwt_log.add_rule "*" Lwt_log.Info

(* Default VyConf configuration *)
let daemonize = ref true
let config_file = ref defaults.config_file
let basepath = ref "/"
let log_file = ref None

(* Global data *)
let sessions : (string, Session.session_data) Hashtbl.t = Hashtbl.create 10

let commit_lock : string option ref = ref None

let conf_mode_lock : string option ref = ref None

(* Command line arguments *)
let args = [
    ("--no-daemon", Arg.Unit (fun () -> daemonize := false), "Do not daemonize");
    ("--config", Arg.String (fun s -> config_file := s),
    (Printf.sprintf "<string>  Configuration file, default is %s" defaults.config_file));
    ("--log-file", Arg.String (fun s -> log_file := Some s), "<string>  Log file");
    ("--base-path", Arg.String (fun s -> basepath := s), "<string>  Appliance base path");
    ("--version", Arg.Unit (fun () -> print_endline @@ Version.version_info (); exit 0), "Print version and exit")
   ]
let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let response_tmpl = {status=Success; output=None; error=None; warning=None}

let make_session_token () =
    Sha1.string (string_of_int (Random.bits ())) |> Sha1.to_hex

let setup_session world req =
    let token = make_session_token () in
    let user = "unknown user" in
    let client_app = Option.value req.client_application ~default:"unknown client" in
    let () = Hashtbl.add sessions token (Session.make world client_app user) in
    {response_tmpl with output=(Some token)}

let find_session token = Hashtbl.find sessions token

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

let teardown token =
    try
        Hashtbl.remove sessions token;
        {response_tmpl with status=Success}
    with Not_found ->
        {response_tmpl with status=Fail; error=(Some "Session not found")}

let exists world token (req: request_exists) =
    if Session.exists world (find_session token) req.path then response_tmpl
    else {response_tmpl with status=Fail}

let get_value world token (req: request_get_value) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let value = Session.get_value world (find_session token) req.path in
        let fmt = Option.value req.output_format ~default:Out_plain in
        let value_str =
         (match fmt with
          | Out_plain -> value
          | Out_json -> Yojson.Safe.to_string @@ `String value)
        in {response_tmpl with output=(Some value_str)}
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let get_values world token (req: request_get_values) =
    try
        let values = Session.get_values world (find_session token) req.path in
        let fmt = Option.value req.output_format ~default:Out_plain in
        let values_str =
         (match fmt with
          | Out_plain -> Vyos1x.Util.string_of_list @@ List.map (Printf.sprintf "\'%s\'") values
          | Out_json -> Vyos1x.Util.json_of_list values)
        in {response_tmpl with output=(Some values_str)}
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let list_children world token (req: request_list_children) =
    try
        let children = Session.list_children world (find_session token) req.path in
        let fmt = Option.value req.output_format ~default:Out_plain in
        let children_str =
          (match fmt with
          | Out_plain -> Vyos1x.Util.string_of_list @@ List.map (Printf.sprintf "\'%s\'") children
          | Out_json -> Vyos1x.Util.json_of_list children)
         in {response_tmpl with output=(Some children_str)}
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let show_config world token (req: request_show_config) =
    try
        let fmt = Option.value req.format ~default:Curly in
        let conf_str = Session.show_config world (find_session token) req.path fmt in
        {response_tmpl with output=(Some conf_str)}
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let validate world token (req: request_validate) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let () = Session.validate world (find_session token) req.path in
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let reload_reftree world (_req: request_reload_reftree) =
    let config = world.Session.vyconf_config in
    let reftree =
        Startup.read_reference_tree (FP.concat config.reftree_dir config.reference_tree)
    in
    match reftree with
    | Ok reftree ->
        world.reference_tree <- reftree;
        {response_tmpl with status=Success}
    | Error s -> {response_tmpl with status=Fail; error=(Some s)}

let send_response oc resp =
    let enc = Pbrt.Encoder.create () in
    let%lwt () = encode_pb_response resp enc |> return in
    let%lwt resp_msg = Pbrt.Encoder.to_bytes enc |> return in
    let%lwt () = Vyconf_connect.Message.write oc resp_msg in
    Lwt.return ()

let rec handle_connection world ic oc () =
    try%lwt
        let%lwt req_msg = Vyconf_connect.Message.read ic in
        let%lwt req =
            try
                let envelope = decode_pb_request_envelope (Pbrt.Decoder.of_bytes req_msg) in
                Lwt.return (Ok (envelope.token, envelope.request))
            with Pbrt.Decoder.Failure e -> Lwt.return (Error (Pbrt.Decoder.error_to_string e))
        in
        let%lwt resp =
            (match req with
            | Error msg -> {response_tmpl with status=Fail; error=(Some (Printf.sprintf "Decoding error: %s" msg))}
            | Ok req ->
               begin
                    match req with
                    | _, Status -> response_tmpl
                    | _, Setup_session r -> setup_session world r
                    | _, Reload_reftree r -> reload_reftree world r
                    | None, _ -> {response_tmpl with status=Fail; output=(Some "Operation requires session token")}
                    | Some t, Teardown _ -> teardown t
                    | Some t, Configure r -> enter_conf_mode r t
                    | Some t, Exit_configure -> exit_conf_mode world t
                    | Some t, Exists r -> exists world t r
                    | Some t, Get_value r -> get_value world t r
                    | Some t, Get_values r -> get_values world t r
                    | Some t, List_children r -> list_children world t r
                    | Some t, Show_config r -> show_config world t r
                    | Some t, Validate r -> validate world t r
                    | _ -> failwith "Unimplemented"
                end) |> Lwt.return
        in
        let%lwt () = send_response oc resp in
        handle_connection world ic oc ()
    with
    | Failure e -> 
        let%lwt () = Lwt_log.error e in
        let%lwt () = send_response oc ({response_tmpl with status=Fail; error=(Some e)}) in
        handle_connection world ic oc ()
    | End_of_file -> Lwt_log.info "Connection closed" >>= (fun () -> Lwt_io.close ic) >>= return

let accept_connection world conn =
    let fd, _ = conn in
    let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
    Lwt.on_failure (handle_connection world ic oc ()) (fun e -> Lwt_log.ign_error (Printexc.to_string e));
    Lwt_log.info "New connection" >>= return

let main_loop basepath world () =
    let open Session in
    let log_file = Option.bind !log_file (fun s -> Some (FP.concat basepath s)) in
    let%lwt () = Startup.setup_logger !daemonize log_file world.vyconf_config.log_template in
    let%lwt () = Lwt_log.notice @@ Printf.sprintf "Starting VyConf for %s" world.vyconf_config.app_name in
    let%lwt sock = Startup.create_socket (FP.concat basepath world.vyconf_config.socket) in
    let%lwt serve = Startup.create_server (accept_connection world) sock () in
    serve ()

let load_interface_definitions dir =
    let reftree = Gen.load_interface_definitions dir in
    match reftree with
    | Ok r -> r
    | Error s -> Startup.panic s

let read_reference_tree file =
    let reftree = Startup.read_reference_tree file in
    match reftree with
    | Ok r -> r
    | Error s -> Startup.panic s

let make_world config dirs =
    let open Session in
    (* the reference_tree json file is generated at vyos-1x build time *)
    let reftree = read_reference_tree (FP.concat config.reftree_dir config.reference_tree) in
    let running_config = CT.make "" in
    {running_config=running_config; reference_tree=reftree; vyconf_config=config; dirs=dirs}

let () = 
  let () = Arg.parse args (fun _ -> ()) usage in
  let vc = Startup.load_daemon_config !config_file in
  let () = Lwt_log.load_rules ("* -> " ^ vc.log_level) in
  let dirs = Directories.make !basepath vc in
  Startup.check_validators_dir dirs;
  let world = make_world vc dirs in
  let config = Startup.load_config_failsafe
      (FP.concat vc.config_dir vc.primary_config)
      (FP.concat vc.config_dir vc.fallback_config) in
  let world = Session.{world with running_config=config} in
  Lwt_main.run @@ main_loop !basepath world ()
