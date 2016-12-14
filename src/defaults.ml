type vyconf_defaults = {
    config_file: string;
    pid_file: string;
    socket: string;
}

let defaults = {
    config_file = "/etc/vyconfd.conf";
    pid_file = "/var/run/vyconfd.pid";
    socket = "/var/run/vyconfd.sock";
}
