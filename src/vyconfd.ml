open Lwt

open Vyconf_connect.Vyconf_pbt
open Vyconfd_config.Defaults
open Vyconfd_config.Vyconf_config

module CT = Vyos1x.Config_tree
module IC = Vyos1x.Internal.Make(CT)
module CC = Commitd_client.Commit
module VC = Commitd_client.Vycall_client
module FP = FilePath
module Gen = Vyos1x.Generate
module Session = Vyconfd_config.Session
module Directories = Vyconfd_config.Directories
module Startup = Vyconfd_config.Startup

(* On UNIX, self_init uses /dev/random for seed *)
let () = Random.self_init ()

let () = Lwt_log.add_rule "*" Lwt_log.Info

(* Default VyConf configuration *)
let daemonize = ref true
let config_file = ref defaults.config_file
let basepath = ref "/"
let log_file = ref None
let legacy_config_path = ref false
let reload_active_config = ref false

(* Global data *)
let sessions : (string, Session.session_data) Hashtbl.t = Hashtbl.create 10

let commit_lock : int32 option ref = ref None

let conf_mode_lock : int32 option ref = ref None

(* Command line arguments *)
let args = [
    ("--no-daemon", Arg.Unit (fun () -> daemonize := false), "Do not daemonize");
    ("--config", Arg.String (fun s -> config_file := s),
    (Printf.sprintf "<string>  Configuration file, default is %s" defaults.config_file));
    ("--log-file", Arg.String (fun s -> log_file := Some s), "<string>  Log file");
    ("--base-path", Arg.String (fun s -> basepath := s), "<string>  Appliance base path");
    ("--version", Arg.Unit (fun () -> print_endline @@ Version.version_info (); exit 0), "Print version and exit");
    ("--legacy-config-path", Arg.Unit (fun () -> legacy_config_path := true),
    (Printf.sprintf "Load config file from legacy path %s" defaults.legacy_config_path));
    ("--reload-active-config", Arg.Unit (fun () -> reload_active_config := true), "Reload active config file");
   ]
let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let response_tmpl = {status=Success; output=None; error=None; warning=None}

let find_session token = Hashtbl.find sessions token

let find_session_by_pid pid =
    let exception E of string in
    let find_k k v acc =
        if v.Session.client_pid = pid then
            raise_notrace (E k)
        else acc
    in
    try
        Hashtbl.fold find_k sessions None
    with E x -> Some x

let make_session_token () =
    Sha1.string (string_of_int (Random.bits ())) |> Sha1.to_hex

let setup_session world (req: request_setup_session) =
    let token = make_session_token () in
    let pid = req.client_pid in
    let user =
        match req.client_user with
        | None -> ""
        | Some u -> u
    in
    let sudo_user =
        match req.client_sudo_user with
        | None -> ""
        | Some u -> u
    in
    let client_app = Option.value req.client_application ~default:"unknown client" in
    let () = Hashtbl.add sessions token (Session.make world client_app sudo_user user pid) in
    {response_tmpl with output=(Some token)}

let session_of_pid _world (req: request_session_of_pid) =
    let pid = req.client_pid in
    let extant = find_session_by_pid pid in
    {response_tmpl with output=extant}

let session_exists _world token (_req: request_session_exists) =
    try
        let _ = Hashtbl.find sessions token in
        {response_tmpl with output=(Some token)}
    with Not_found -> {response_tmpl with status=Fail; output=None}

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
    | Some pid ->
        if req.override_exclusive then aux token session
        else
        {response_tmpl with
           status=Configuration_locked;
           error=Some (Printf.sprintf "Configuration was locked by %ld" pid)}
    | None ->
        if req.exclusive then (conf_mode_lock := Some session.client_pid; aux token session)
        else aux token session

let exit_conf_mode _world token =
    let open Session in
    let session = Hashtbl.find sessions token in
    let session = {session with
        changeset = [];
        modified = false}
    in Hashtbl.replace sessions token session;
    response_tmpl

let teardown world token =
    try
        let () = Hashtbl.remove sessions token in
        let () = Session.cleanup_config world token in
        {response_tmpl with status=Success}
    with Not_found ->
        {response_tmpl with status=Fail; error=(Some "Session not found")}

let session_changed world token (_req: request_session_changed) =
    if Session.session_changed world (find_session token) then response_tmpl
    else {response_tmpl with status=Fail}

let get_config world token (_req: request_get_config) =
    try
        let id =
            Session.get_config world (find_session token) token
        in {response_tmpl with output=(Some id)}
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

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
        let conf_str = Session.show_config world (find_session token) req.path in
        {response_tmpl with output=(Some conf_str)}
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let show_sessions _world token (req: request_show_sessions) =
    let g d s =
        (Session.session_data_to_yojson d) :: s
    in
    let f k d s =
        match k with
        | t when t = token ->
            if req.exclude_self then s
            else g d s
        | _ ->
            if req.exclude_other then s
            else g d s
    in
    let tmp = Hashtbl.fold f sessions [] in
    let res = Yojson.Safe.to_string @@ `List tmp in
    {response_tmpl with output=(Some res)}

let validate world token (req: request_validate) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let () = Session.validate world (find_session token) req.path in
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let set world token (req: request_set) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let session = Session.set world (find_session token) req.path in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let delete world token (req: request_delete) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let session = Session.delete world (find_session token) req.path in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let aux_set world token (req: request_aux_set) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let () =
            Session.aux_set
            world
            (find_session token)
            req.path
            req.script_name
            req.tag_value
        in
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let aux_delete world token (req: request_aux_delete) =
    try
        let () = (Lwt_log.debug @@ Printf.sprintf "[%s]\n" (Vyos1x.Util.string_of_list req.path)) |> Lwt.ignore_result in
        let () =
            Session.aux_delete
            world
            (find_session token)
            req.path
            req.script_name
            req.tag_value
        in
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let discard world token (_req: request_discard) =
    try
        let session = Session.discard world (find_session token)
        in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let copy world token (req: request_copy) =
    try
        let session = Session.copy world (find_session token) req.source req.destination
        in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let rename world token (req: request_rename) =
    try
        let session = Session.rename world (find_session token) req.source req.destination
        in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let load world token (req: request_load) =
    try
        let session = Session.load world (find_session token) req.location req.cached
        in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let merge world token (req: request_merge) =
    try
        let session = Session.merge world (find_session token) req.location req.destructive
        in
        Hashtbl.replace sessions token session;
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let save world token (req: request_save) =
    try
        let _ = Session.save world (find_session token) req.location
        in
        response_tmpl
    with Session.Session_error msg -> {response_tmpl with status=Fail; error=(Some msg)}

let commit world token (req: request_commit) =
    let s = find_session token in
    let proposed_config = Session.get_proposed_config world s in
    let req_dry_run = Option.value req.dry_run ~default:false in
    let commit_data =
        Session.prepare_commit ~dry_run:req_dry_run world s proposed_config token
    in
    match commit_data with
    | Error msg ->
        Lwt.return {response_tmpl with status=Internal_error; error=(Some msg)}
    | Ok c_data ->
    let%lwt received_commit_data = VC.do_commit c_data in
    let%lwt result_commit_data =
        Lwt.return (CC.commit_update received_commit_data)
    in
    match result_commit_data.init with
    | None ->
        let out = "Empty init" in
        Lwt.return {response_tmpl with status=Internal_error; error=(Some out)}
    | Some init_data ->
        let res, out =
            init_data.success, init_data.out
        in
        let () =
            (Lwt_log.debug @@ Printf.sprintf "aux_changeset: %s" (Session.sprint_changeset s.aux_changeset)) |> Lwt.ignore_result
        in
        match res with
        | false ->
            Lwt.return {response_tmpl with status=Internal_error; error=(Some out)}
        | true ->
            if not req_dry_run then
                let post_running, post_proposed =
                    Session.post_process_commit world s (result_commit_data, proposed_config)
                in
                world.Session.running_config <- post_running;
                let session =
                    { s with changeset =
                        Session.get_changeset
                        world
                        s
                        world.Session.running_config
                        post_proposed;
                        aux_changeset = []; }
                in
                Hashtbl.replace sessions token session
            else ();

            let write_msg =
                if not req_dry_run then
                    match Session.write_running_cache world with
                    | Ok () -> ""
                    | Error msg -> msg
                else ""
            in
            let success, result_msg =
                result_commit_data.result.success, result_commit_data.result.out
            in
            let msg_str =
                match write_msg with
                | "" -> result_msg
                | _ -> Printf.sprintf "%s\n %s" result_msg write_msg
            in
            match success with
            | true -> Lwt.return {response_tmpl with status=Success; output=(Some msg_str)}
            | false -> Lwt.return {response_tmpl with status=Fail; output=(Some msg_str)}

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

let set_edit_level world token (req: request_set_edit_level) =
    let s = find_session token in
    try
        let session, edit_env =
            Session.set_edit_level world s req.path
        in
        Hashtbl.replace sessions token session;
        {response_tmpl with output=(Some edit_env)}
    with Session.Session_error msg ->
        {response_tmpl with status=Fail; error=(Some msg)}

let set_edit_level_up world token (_req: request_set_edit_level_up) =
    let s = find_session token in
    try
        let session, edit_env =
            Session.set_edit_level_up world s
        in
        Hashtbl.replace sessions token session;
        {response_tmpl with output=(Some edit_env)}
    with Session.Session_error msg ->
        {response_tmpl with status=Fail; error=(Some msg)}

let reset_edit_level world token (_req: request_reset_edit_level) =
    let s = find_session token in
    try
        let session, edit_env =
            Session.reset_edit_level world s
        in
        Hashtbl.replace sessions token session;
        {response_tmpl with output=(Some edit_env)}
    with Session.Session_error msg ->
        {response_tmpl with status=Fail; error=(Some msg)}

let get_edit_level world token (_req: request_get_edit_level) =
    let s = find_session token in
    try
        let edit_env = Session.get_edit_level world s in
        {response_tmpl with output=(Some edit_env)}
    with Session.Session_error msg ->
        {response_tmpl with status=Fail; error=(Some msg)}

let edit_level_root world token (_req: request_edit_level_root) =
    if Session.edit_level_root world (find_session token) then response_tmpl
    else {response_tmpl with status=Fail}

let config_unsaved world token (req: request_config_unsaved) =
    let saved_file =
        match req.file with
        | None -> defaults.legacy_config_path
        | Some file -> file
    in
    if Session.config_unsaved world (find_session token) saved_file token
    then response_tmpl
    else {response_tmpl with status=Fail}

let reference_path_exists world token (req: request_reference_path_exists) =
    let path = req.path in
    if Session.reference_path_exists world (find_session token) path
    then response_tmpl
    else {response_tmpl with status=Fail}

let get_path_type world token (req: request_get_path_type) =
    let s = find_session token in
    try
        let node_type =
            Session.get_path_type ~legacy_format:req.legacy_format world s req.path
        in
        {response_tmpl with output=(Some node_type)}
    with Session.Session_error msg ->
        {response_tmpl with status=Fail; error=(Some msg)}

let get_completion_env world token (req: request_get_completion_env) =
    let s = find_session token in
    try
        let node_type =
            Session.get_completion_env
            ~legacy_format:req.legacy_format world s req.path
        in
        {response_tmpl with output=(Some node_type)}
    with Session.Session_error msg ->
        {response_tmpl with status=Fail; error=(Some msg)}

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
            match req with
            | Error msg -> Lwt.return {response_tmpl with status=Fail; error=(Some (Printf.sprintf "Decoding error: %s" msg))}
            | Ok req ->
               match req with
               | Some t, Commit r -> commit world t r
               | _ as req ->
               begin
                    (match req with
                    | _, Prompt -> response_tmpl
                    | _, Setup_session r -> setup_session world r
                    | _, Session_of_pid r -> session_of_pid world r
                    | _, Reload_reftree r -> reload_reftree world r
                    | None, _ -> {response_tmpl with status=Fail; output=(Some "Operation requires session token")}
                    | Some t, Session_exists r -> session_exists world t r
                    | Some t, Teardown _ -> teardown world t
                    | Some t, Enter_configuration_mode r -> enter_conf_mode r t
                    | Some t, Exit_configuration_mode -> exit_conf_mode world t
                    | Some t, Exists r -> exists world t r
                    | Some t, Get_value r -> get_value world t r
                    | Some t, Get_values r -> get_values world t r
                    | Some t, List_children r -> list_children world t r
                    | Some t, Show_config r -> show_config world t r
                    | Some t, Validate r -> validate world t r
                    | Some t, Set r -> set world t r
                    | Some t, Delete r -> delete world t r
                    | Some t, Aux_set r -> aux_set world t r
                    | Some t, Aux_delete r -> aux_delete world t r
                    | Some t, Discard r -> discard world t r
                    | Some t, Session_changed r -> session_changed world t r
                    | Some t, Get_config r -> get_config world t r
                    | Some t, Load r -> load world t r
                    | Some t, Merge r -> merge world t r
                    | Some t, Save r -> save world t r
                    | Some t, Show_sessions r -> show_sessions world t r
                    | Some t, Set_edit_level r -> set_edit_level world t r
                    | Some t, Set_edit_level_up r -> set_edit_level_up world t r
                    | Some t, Reset_edit_level r -> reset_edit_level world t r
                    | Some t, Get_edit_level r -> get_edit_level world t r
                    | Some t, Edit_level_root r -> edit_level_root world t r
                    | Some t, Config_unsaved r -> config_unsaved world t r
                    | Some t, Reference_path_exists r -> reference_path_exists world t r
                    | Some t, Get_path_type r -> get_path_type world t r
                    | Some t, Get_completion_env r -> get_completion_env world t r
                    | Some t, Copy r -> copy world t r
                    | Some t, Rename r -> rename world t r
                    | _ -> failwith "Unimplemented"
                    ) |> Lwt.return
               end
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

let init_write_cache world =
    (* initial cache of running config; this will be unnecessary once
       vyconfd is started at boot *)
    let res = Session.write_running_cache world in
    match res with
    | Ok _ ->  ()
    | Error msg -> (Lwt_log.error msg) |> Lwt.ignore_result

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
  let primary_config =
      match !legacy_config_path with
      | true -> defaults.legacy_config_path
      | false -> (FP.concat vc.config_dir vc.primary_config)
  in
  let failsafe_config = (FP.concat vc.config_dir vc.fallback_config) in
  let restart_cache = (FP.concat vc.session_dir vc.running_cache) in
  let config =
      match !reload_active_config with
      | true -> let res = Startup.load_config_cache restart_cache in
                begin
                match res with
                | Ok c -> c
                | Error msg ->
                    let () = (Lwt_log.error msg) |> Lwt.ignore_result in
                    Startup.load_config_failsafe primary_config failsafe_config
                end
      | false -> Startup.load_config_failsafe primary_config failsafe_config
  in
  let world = Session.{world with running_config=config} in
  let () =
      match !reload_active_config with
      | true -> ()
      | false -> init_write_cache world
  in
  Lwt_main.run @@ main_loop !basepath world ()
