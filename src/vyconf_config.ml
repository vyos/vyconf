type vyconf_config = {
    app_name: string;
    app_dir: string;
    config_dir: string;
    primary_config: string;
    fallback_config: string;
    socket: string;
} [@@deriving yojson]


let load filename =
    try Yojson.Safe.from_file filename |> vyconf_config_of_yojson
    with Sys_error msg -> `Error msg

