type t = {
    app_name: string;
    data_dir: string;
    program_dir: string;
    config_dir: string;
    primary_config: string;
    fallback_config: string;
    socket: string;
    pid_file: string;
    log_file: string option;
}

val load : string -> (t, string) result

val dump : t -> string
