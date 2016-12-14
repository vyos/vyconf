type vyconf_defaults = {
    config_file: string;
    version: string;
    pid_file: string;
    socket: string;
}

let defaults = {
    config_file = "/etc/vyconfd.conf";
    version = "0.0.1";
    pid_file = "/var/run/vyconfd.pid";
    socket = "/var/run/vyconfd.sock";
}
