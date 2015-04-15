type value_constraint = Regex of string | External of string * string

exception Bad_validator of string

let validate_value validators value_constraint value =
    match value_constraint with
    | Regex s ->      
        (try 
           let _ = Pcre.exec ~pat:s value in true
       with Not_found -> false)
    | External (t, c) ->
        try
            let validator = Hashtbl.find validators t in
            let result = Unix.system (Printf.sprintf "%s %s %s" validator c value) in
            match result with
            | Unix.WEXITED 0 -> true
            | _ -> false
        with Not_found -> raise (Bad_validator t)
