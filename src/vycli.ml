open Client.Vyconf_client
open Vyconf_connect.Vyconf_pbt

type op_t =
    | OpStatus
    | OpSetupSession
    | OpTeardownSession
    | OpShowConfig
    | OpExists
    | OpGetValue
    | OpGetValues
    | OpListChildren
    | OpValidate
    | OpReloadReftree

let token : string option ref = ref None
let conf_format_opt = ref "curly"
let out_format_opt = ref "plain"
let socket = ref ""
let path_opt = ref ""
let op = ref None

(* Command line arguments *)
let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let args = [
    ("--config-format", Arg.String (fun s -> conf_format_opt := s), "<curly|json>  Configuration output format, default is curly");
    ("--out-format", Arg.String (fun s -> out_format_opt := s), "<plain|json>  Operational mode output format, default is plain");
    ("--token", Arg.String (fun s -> token := Some s), "<string>  Session token");
    ("--socket", Arg.String (fun s -> socket := s), "<string>  Socket file path");
    ("--setup-session", Arg.Unit (fun () -> op := Some OpSetupSession), "Setup a configuration session");
    ("--path", Arg.String (fun s -> path_opt := s), "<string> Configuration path");
    ("--get-value", Arg.Unit (fun () -> op := Some OpGetValue), "Get value at the specified path");
    ("--get-values", Arg.Unit (fun () -> op := Some OpGetValues), "Get values at the specified path");
    ("--exists", Arg.Unit (fun () -> op := Some OpExists), "Check if specified path exists");
    ("--list-children", Arg.Unit (fun () -> op := Some OpListChildren), "List children of the node at the specified path");
    ("--show-config", Arg.Unit (fun () -> op := Some OpShowConfig), "Show the configuration at the specified path");
    ("--status", Arg.Unit (fun () -> op := Some OpStatus), "Send a status/keepalive message");
    ("--validate", Arg.Unit (fun () -> op := Some OpValidate), "Validate path");
    ("--reload-reftree", Arg.Unit (fun () -> op := Some OpReloadReftree), "Reload reference tree");
   ]

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

let main socket op path out_format config_format =
    let%lwt client = Client.Vyconf_client.create ~token:!token socket out_format config_format in
    let%lwt result = match op with
    | None -> Error "Operation required" |> Lwt.return
    | Some o ->
        begin
            match o with
            | OpStatus ->
                let%lwt resp = get_status client in
                begin
                    match resp.status with
                    | Success -> Ok "" |> Lwt.return
                    | _ -> Error (Option.value resp.error ~default:"") |> Lwt.return
                end
            | OpSetupSession ->
                let%lwt resp = setup_session client "vycli" in
                begin
                    match resp with
                    | Ok c -> get_token c
                    | Error e -> Error e |> Lwt.return
                end
            | OpExists -> exists client path
            | OpGetValue -> get_value client path
            | OpGetValues -> get_values client path
            | OpListChildren -> list_children client path
            | OpShowConfig -> show_config client path
            | OpValidate -> validate client path
            | OpReloadReftree -> reload_reftree client
            | _ -> Error "Unimplemented" |> Lwt.return
        end
    in match result with
    | Ok s -> let%lwt () = Lwt_io.write Lwt_io.stdout s in Lwt.return 0
    | Error e -> let%lwt () = Lwt_io.write Lwt_io.stderr (Printf.sprintf "%s\n" e) in Lwt.return 1

let _ =
    let () = Arg.parse args (fun _ -> ()) usage in
    let path = Vyos1x.Util.list_of_path !path_opt in
    let out_format = output_format_of_string !out_format_opt in
    let config_format = config_format_of_string !conf_format_opt in
    let result = Lwt_main.run (main !socket !op path out_format config_format) in exit result
