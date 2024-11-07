open Vyconf_connect.Vyconf_pbt

type op_t =
    | OpSetupSession
    | OpExists
    | OpTeardownSession
    | OpShowConfig
    | OpValidate

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

let call_op ?(out_format="plain") ?(config_format="curly") socket token op path =
    let config_format = config_format_of_string config_format in
    let out_format = output_format_of_string out_format in
    let run =
        let%lwt client =
            Vyconf_client.create ~token:token socket out_format config_format
        in
        let%lwt result = match op with
        | None -> Error "Operation required" |> Lwt.return
        | Some o ->
            begin
            match o with
            | OpSetupSession ->
                let%lwt resp = Vyconf_client.setup_session client "vyconf_client_session" in
                begin
                    match resp with
                    | Ok c -> Vyconf_client.get_token c
                    | Error e -> Error e |> Lwt.return
                end
            | OpExists -> Vyconf_client.exists client path
            | OpTeardownSession -> Vyconf_client.teardown_session client
            | OpShowConfig -> Vyconf_client.show_config client path
            | OpValidate -> Vyconf_client.validate client path
            end
        in
        Lwt.return result
    in
    Lwt_main.run run

let session_init ?(out_format="plain") ?(config_format="curly") socket =
    call_op ~out_format:out_format ~config_format:config_format socket None (Some OpSetupSession) []

let session_free socket token =
    call_op socket (Some token) (Some OpTeardownSession) []

let session_validate_path socket token path =
    call_op socket (Some token) (Some OpValidate) path

let session_show_config socket token path =
    call_op socket (Some token) (Some OpShowConfig) path

let session_path_exists socket token path =
    call_op socket (Some token) (Some OpExists) path
