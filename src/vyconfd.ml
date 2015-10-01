open Lwt
open Defaults

let () = Lwt_log.add_rule "*" Lwt_log.Info

let config =
    let result = Vyconf_config.load defaults.config_file in
    match result with
    | `Ok cfg -> cfg
    | `Error err ->
        Lwt_log.fatal (Printf.sprintf "Could not load the configuration file %s" err); exit 1



let () = print_endline "This is VyConf. Or, rather, will be."
