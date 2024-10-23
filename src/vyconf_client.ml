include Vyconf_connect.Vyconf_pb
include Vyconf_connect.Vyconf_types

type t = {
    sock: Lwt_unix.file_descr;
    ic: Lwt_io.input Lwt_io.channel;
    oc: Lwt_io.output Lwt_io.channel;
    enc: Pbrt.Encoder.t;
    session: string option;
    conf_mode: bool;
    closed: bool;
    out_format: request_output_format;
    conf_format: request_config_format
}

let unwrap o =
    match o with
    | Some v -> Ok v
    | None -> Error "operation returned None when actual value was expected"

let create ?(token=None) sockfile out_format conf_format =
    let open Lwt_unix in
    let sock = socket PF_UNIX SOCK_STREAM 0 in
    let%lwt () = connect sock (ADDR_UNIX sockfile) in
    let ic = Lwt_io.of_fd ~mode:Lwt_io.Input sock in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.Output sock in
    Lwt.return {
      sock=sock; ic=ic; oc=oc;
      enc=(Pbrt.Encoder.create ()); closed=false;
      session=token; conf_mode=false; out_format=out_format;
      conf_format=conf_format
    }

let get_token client = 
    let token = client.session in
    match token with
    | Some t -> Ok t |> Lwt.return
    | None -> Error "failed to get a session token" |> Lwt.return

let shutdown client =
    let%lwt () = Lwt_unix.close client.sock in
    Lwt.return {client with closed=true}

let do_request client req =
    let enc = Pbrt.Encoder.create () in
    let () = encode_request_envelope {token=client.session; request=req} enc in
    let msg = Pbrt.Encoder.to_bytes enc in
    let%lwt () = Vyconf_connect.Message.write client.oc msg in
    let%lwt resp = Vyconf_connect.Message.read client.ic in
    decode_response (Pbrt.Decoder.of_bytes resp) |> Lwt.return

let get_status client =
    let req = Status in
    let%lwt resp = do_request client req in
    Lwt.return resp

let setup_session ?(on_behalf_of=None) client client_app =
    if Option.is_some client.session then Lwt.return (Error "Client is already associated with a session") else
    let id = on_behalf_of |> (function None -> None | Some x -> (Some (Int32.of_int x))) in
    let req = Setup_session {client_application=(Some client_app); on_behalf_of=id} in
    let%lwt resp = do_request client req in
    match resp.status with
    | Success ->
        (match resp.output with
         | Some token -> Ok {client with session=(Some token)}
         | None -> Error "setup_session did not return a session token!") |> Lwt.return
    | _ -> Error (Option.value resp.error ~default:"Unknown error") |> Lwt.return

let exists client path =
    let req = Exists {path=path} in
    let%lwt resp = do_request client req in
    match resp.status with
    | Success -> Lwt.return (Ok "")
    | Fail -> Lwt.return (Error "")
    | _ -> Error (Option.value resp.error ~default:"") |> Lwt.return

let get_value client path =
    let req = Get_value {path=path; output_format=(Some client.out_format)} in
    let%lwt resp = do_request client req in
    match resp.status with
    | Success -> unwrap resp.output |> Lwt.return
    | _ -> Error (Option.value resp.error ~default:"") |> Lwt.return

let get_values client path =
    let req = Get_values {path=path; output_format=(Some client.out_format)} in
    let%lwt resp = do_request client req in
    match resp.status with
    | Success -> unwrap resp.output |> Lwt.return
    | _ -> Error (Option.value resp.error ~default:"") |> Lwt.return

let list_children client path =
    let req = List_children {path=path; output_format=(Some client.out_format)} in
    let%lwt resp = do_request client req in
    match resp.status with
    | Success -> unwrap resp.output |> Lwt.return
    | _ -> Error (Option.value resp.error ~default:"") |> Lwt.return

let show_config client path =
    let req = Show_config {path=path; format=(Some client.conf_format)} in
    let%lwt resp = do_request client req in
    match resp.status with
    | Success -> unwrap resp.output |> Lwt.return
    | _ -> Error (Option.value resp.error ~default:"") |> Lwt.return

