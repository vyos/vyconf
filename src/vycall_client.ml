(* send commit data to Python commit daemon *)

open Vycall_message.Vycall_pbt
open Commit

module CT = Vyos1x.Config_tree
module IC = Vyos1x.Internal.Make(CT)
module FP = FilePath

type t = {
    ic: Lwt_io.input Lwt_io.channel;
    oc: Lwt_io.output Lwt_io.channel;
}

(* explicit translation between commit data and commit protobuf
 * to keep the commit data opaque to protobuf message definition.
 * The commit daemon updates the (subset of) commit data with
 * results of script execution in init/reply fields.
 *)
let node_data_to_call nd =
    { script_name = nd.script_name;
      tag_value = nd.tag_value;
      arg_value = nd.arg_value;
      reply = None
    }

let call_to_node_data ((c: call), (nd: node_data)) =
    match c.reply with
    | None -> nd
    | Some r -> { nd with reply = Some { success = r.success; out = r.out }}

let commit_data_to_commit_proto cd =
    { session_id = cd.session_id;
      dry_run = cd.dry_run;
      atomic = cd.atomic;
      background = cd.background;
      init = None;
      calls = List.map node_data_to_call cd.node_list;
    }

let commit_proto_to_commit_data (c: commit) (cd: commit_data) =
    match c.init with
    | None -> cd
    | Some i ->
        { cd with init = Some { success = i.success; out = i.out };
          node_list =
              List.map call_to_node_data (List.combine c.calls cd.node_list);
        }

(* read/write message from/to socket *)
let call_write oc msg =
    let length = Bytes.length msg in
    let length' = Int32.of_int length in
    if length' < 0l then failwith (Printf.sprintf "Bad message length: %d" length) else
    let header = Bytes.create 4 in
    let () = EndianBytes.BigEndian.set_int32 header 0 length' in
    let%lwt () = Lwt_io.write_from_exactly oc header 0 4 in
    Lwt_io.write_from_exactly oc msg 0 length

let call_read ic =
    let header = Bytes.create 4 in
    let%lwt () = Lwt_io.read_into_exactly ic header 0 4 in
    let length = EndianBytes.BigEndian.get_int32 header 0 |> Int32.to_int in
    if length < 0 then failwith (Printf.sprintf "Bad message length: %d" length) else
    let buffer = Bytes.create length in
    let%lwt () = Lwt_io.read_into_exactly ic buffer 0 length in
    Lwt.return buffer

(* encode/decode commit data *)
let do_call client request =
    let enc = Pbrt.Encoder.create () in
    let () = encode_pb_commit request enc in
    let msg = Pbrt.Encoder.to_bytes enc in
    let%lwt () = call_write client.oc msg in
    let%lwt resp = call_read client.ic in
    decode_pb_commit (Pbrt.Decoder.of_bytes resp) |> Lwt.return

(* socket management and commit callback *)
let create sockfile =
    let open Lwt_unix in
    let sock = socket PF_UNIX SOCK_STREAM 0 in
    let%lwt () = connect sock (ADDR_UNIX sockfile) in
    let ic = Lwt_io.of_fd ~mode:Lwt_io.Input sock in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.Output sock in
    Lwt.return { ic=ic; oc=oc; }

let do_commit commit_data =
    let session = commit_data_to_commit_proto commit_data in
    let sockfile = "/run/vyos-commitd.sock" in
    let%lwt client = create sockfile in
    let%lwt resp = do_call client session in
    let%lwt () = Lwt_io.close client.oc in
    Lwt.return(commit_proto_to_commit_data resp commit_data)
