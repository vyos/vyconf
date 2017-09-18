module F = Filename

type value_constraint = Regex of string | External of string * string option

exception Bad_validator of string

let validate_value dir value_constraint value =
    match value_constraint with
    | Regex s ->
        (try
           let _ = Pcre.exec ~pat:s value in true
       with Not_found -> false)
    | External (v, c) ->
        (* XXX: Using Unix.system is a bad idea on multiple levels,
                especially when the input comes directly from the user...
                We should do something about it.
         *)
        let validator = F.concat dir v in
        let arg = BatOption.default "" c in
        let safe_arg = Printf.sprintf "'%s'" (Pcre.qreplace ~pat:"\"" ~templ:"\\\"" arg) in
        let result = Unix.system (Printf.sprintf "%s %s %s" validator safe_arg value) in
        match result with
        | Unix.WEXITED 0 -> true
        | Unix.WEXITED 127 -> raise (Bad_validator (Printf.sprintf "Could not execute validator %s" validator))
        | _ -> false

(* If no constraints given, consider it valid.
   Otherwise consider it valid if it satisfies at least
   one constraint *)
let validate_any validators constraints value =
    let rec aux validators constraints value  =
        match constraints with
        | [] -> false
        | c :: cs -> if validate_value validators c value then true
                     else aux validators cs value
    in
    match constraints with
    | [] -> true
    | _ -> aux validators constraints value
