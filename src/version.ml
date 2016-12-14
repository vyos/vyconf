let version = "0.0.1"

let copyright = "2016, VyOS maintainers and contributors"

let license = "LGPL version 2 or later with OCaml linking exception"

let version_info () =
    let tmpl =
      "VyConf version: %s\n" ^^
      "Copyright %s\n\n" ^^
      "This program is free software, you can use, modify, and redistribute it\n" ^^
      "under the terms of %s\n"
    in Printf.sprintf tmpl version copyright license
