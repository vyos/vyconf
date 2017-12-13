(** The wire protocol of VyConf.

    Messages are preceded by a length header, four bytes in network order.
 *)


let read ic =
    let header = Bytes.create 4 in
    let%lwt () = Lwt_io.read_into_exactly ic header 0 4 in
    let length = EndianBytes.BigEndian.get_int32 header 0 |> Int32.to_int in
    Lwt_log.debug (Printf.sprintf "Read length: %d\n" length) |> Lwt.ignore_result;
    if length < 0 then failwith (Printf.sprintf "Bad message length: %d" length) else
    let buffer = Bytes.create length in
    let%lwt () = Lwt_io.read_into_exactly ic buffer 0 length in
    Lwt_log.debug (Util.hexdump buffer |> Printf.sprintf "Read mesage: %s") |> Lwt.ignore_result;
    Lwt.return buffer

let write oc msg =
    let length = Bytes.length msg in
    let length' = Int32.of_int length in
    Lwt_log.debug (Printf.sprintf "Write length: %d\n" length) |> Lwt.ignore_result;
    Lwt_log.debug (Util.hexdump msg |> Printf.sprintf "Write message: %s") |> Lwt.ignore_result;
    if length' < 0l then failwith (Printf.sprintf "Bad message length: %d" length) else
    let header = Bytes.create 4 in
    let () = EndianBytes.BigEndian.set_int32 header 0 length' in
    let%lwt () = Lwt_io.write_from_exactly oc header 0 4 in
    Lwt_io.write_from_exactly oc msg 0 length
