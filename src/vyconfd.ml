open Defaults

let config = Vyconf_config.load defaults.config_file

let () = print_endline "This is VyConf. Or, rather, will be."
