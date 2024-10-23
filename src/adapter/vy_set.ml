let legacy = ref false
let no_set = ref false
let valid = ref false
let output = ref ""
let path_opt = ref []

let usage = "Usage: " ^ Sys.argv.(0) ^ " [options]"

let read_path p =
    path_opt := p::!path_opt

let speclist = [
    ("--legacy", Arg.Unit (fun _ -> legacy := true), "Use legacy validation");
    ("--no-set", Arg.Unit (fun _ -> no_set := true), "Do not set path");
   ]

let format_out l =
    let fl = List.filter (fun s -> (String.length s) > 0) l in
    String.concat "\n\n" fl

let is_valid v =
    match v with
    | None -> true
    | Some _ -> false

let valid_err v =
    Option.value v ~default:""

let () =
    let () = Arg.parse speclist read_path usage in
    let path_list = List.rev !path_opt in
    let () =
        if List.length path_list = 0 then
            (Printf.printf "no path specified\n"; exit 1)
    in
    let handle =
        if !legacy || not !no_set then
            let h = Vyos1x_adapter.cstore_handle_init () in
            if not (Vyos1x_adapter.cstore_in_config_session_handle h) then
                (Vyos1x_adapter.cstore_handle_free h;
                Printf.printf "not in config session\n"; exit 1)
            else Some h
        else None
    in
    let valid =
        if not !legacy then
            Vyos1x_adapter.vyconf_validate_path path_list
        else
            begin
            let out =
                match handle with
                | Some h -> Vyos1x_adapter.legacy_validate_path h path_list
                | None -> "missing session handle"
            in
            match out with
            | "" -> None
            | _ -> Some out
            end
    in
    let res =
        if not !no_set && (is_valid valid) then
            match handle with
            | Some h ->
                Vyos1x_adapter.cstore_set_path h path_list
            | None -> "missing session handle"
        else ""
    in
    let ret =
        if (is_valid valid) && (res = "") then 0
        else 1
    in
    let output = format_out [(valid_err valid); res] in
    let () =
        match handle with
        | Some h -> Vyos1x_adapter.cstore_handle_free h
        | None -> ()
    in
    let () = print_endline output in
    exit ret
