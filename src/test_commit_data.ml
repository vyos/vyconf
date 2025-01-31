module CT = Vyos1x.Config_tree
module FP = FilePath

let active_config_file = ref ""
let working_config_file = ref ""

let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let args = [
    ("--running-config", Arg.String (fun s -> active_config_file:= s), "running config file");
    ("--proposed-config", Arg.String (fun s -> working_config_file := s), "proposed config file");
   ]

let parse_ct file_name =
    match file_name with
    | "" -> CT.make ""
    | _ ->
        let ic = open_in file_name in
        let s = really_input_string ic (in_channel_length ic) in
        let ct = Vyos1x.Parser.from_string s in
        close_in ic; ct

let () =
    let () = Arg.parse args (fun _ -> ()) usage in
    let af = !active_config_file in
    let wf = !working_config_file in
    let at = parse_ct af in
    let wt = parse_ct wf in
    let out = Vyconfd_config.Commit.show_commit_data at wt
    in print_endline out
