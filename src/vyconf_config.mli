type t = {
    app_name: string;
    data_dir: string;
    program_dir: string;
    config_dir: string;
    reftree_dir: string;
    session_dir: string;
    primary_config: string;
    fallback_config: string;
    reference_tree: string;
    running_cache: string;
    session_cache: string;
    socket: string;
    pid_file: string;
    log_file: string option;
    log_template: string;
    log_level: string;
}

val load : string -> (t, string) result

val dump : t -> string
