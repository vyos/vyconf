type vyconf_defaults = {
    config_file: string;
    pid_file: string;
    socket: string;
    log_template: string;
    log_level: string;
}

val defaults : vyconf_defaults
