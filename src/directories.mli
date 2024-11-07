type t = {
    components: string;
    validators: string;
    migrators: string;
    component_definitions: string;
    interface_definitions: string;
}

val make : string -> Vyconf_config.t -> t

val test : t -> (unit, string) result

val test_validators_dir : t -> (unit, string) result
