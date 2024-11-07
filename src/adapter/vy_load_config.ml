(* Adapter load_config
 *)

open Vyos1x

let read_config filename =
    let ch = open_in filename in
    let s = really_input_string ch (in_channel_length ch) in
    let ct =
        try
            Ok (Parser.from_string s)
        with Vyos1x.Util.Syntax_error (opt, msg) ->
            begin
                match opt with
                | None -> Error msg
                | Some (line, pos) ->
                    let out = Printf.sprintf "%s line %d pos %d\n" msg line pos
                    in Error out
            end
    in
    close_in ch;
    ct

let read_configs f g =
    let l = read_config f in
    let r = read_config g in
    match l, r with
    | Ok left, Ok right -> Ok (left, right)
    | Error msg_l, Error msg_r -> Error (msg_l ^ msg_r)
    | Error msg_l, _ -> Error msg_l
    | _, Error msg_r -> Error msg_r


let args = []
let usage = Printf.sprintf "Usage: %s <config> <new config>" Sys.argv.(0)

let () = if Array.length Sys.argv <> 3 then (Arg.usage args usage; exit 1)

let () =
let left_name = Sys.argv.(1) in
let right_name = Sys.argv.(2) in
let read = read_configs left_name right_name in
let res =
    match read with
    | Ok (left, right) -> Vyos1x_adapter.load_config left right
    | Error msg -> msg
in Printf.printf "%s\n" res
