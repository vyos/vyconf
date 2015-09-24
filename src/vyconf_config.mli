type vyconf_config = {
    app_name: string;
    app_dir: string;
    config_dir: string;
    primary_config: string;
    fallback_config: string;
    socket: string;
}

val load : string -> [ `Error of bytes | `Ok of vyconf_config ]
