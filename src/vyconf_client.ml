include Vyconf_pb

type t = {
    sock: Lwt_unix.file_descr;
    ic: Lwt_io.input Lwt_io.channel;
    oc: Lwt_io.output Lwt_io.channel;
    enc: Pbrt.Encoder.t;
    session: string option;
    conf_mode: bool;
    closed: bool
}

let create sockfile =
    let open Lwt_unix in
    let sock = socket PF_UNIX SOCK_STREAM 0 in
    let%lwt () = connect sock (ADDR_UNIX sockfile) in
    let ic = Lwt_io.of_fd Lwt_io.Input sock in
    let oc = Lwt_io.of_fd Lwt_io.Output sock in
    Lwt.return {
      sock=sock; ic=ic; oc=oc;
      enc=(Pbrt.Encoder.create ()); closed=false;
      session=None; conf_mode=false
    }

let shutdown client =
    let%lwt () = Lwt_unix.close client.sock in
    Lwt.return {client with closed=true}

let do_request client req =
    let enc = Pbrt.Encoder.create () in
    let () = encode_request req enc in
    let msg = Pbrt.Encoder.to_bytes enc in
    let%lwt () = Message.write client.oc msg in
    let%lwt resp = Message.read client.ic in
    decode_response (Pbrt.Decoder.of_bytes resp) |> Lwt.return
    

let get_status client =
    let req = Status in
    let%lwt resp = do_request client req in
    Lwt.return resp
