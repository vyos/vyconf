module F = Filename
module FU = FileUtil

type t = {
    components: string;
    validators: string;
    migrators: string;
    component_definitions: string;
    interface_definitions: string;
}

let relative_dirs = {
    components = "components";
    validators = "validators";
    migrators = "migration";
    component_definitions = "components";
    interface_definitions = "interfaces";
}

let make conf =
    let open Vyconf_config in
    {
      components = F.concat conf.program_dir relative_dirs.components;
      validators = F.concat conf.program_dir relative_dirs.validators;
      migrators = F.concat conf.program_dir relative_dirs.migrators;
      component_definitions = F.concat conf.data_dir relative_dirs.component_definitions;
      interface_definitions = F.concat conf.data_dir relative_dirs.interface_definitions
    }

(** Check if required directories exist
    We do not try to check if they are readable at this point, it's just to fail early
    if they don't even exist and we shouldn't bother trying
 *)
let test dirs =
     let check_dir d =
         if FU.test FU.Is_dir d then ()
         else raise (Failure (Printf.sprintf "%s does not exist or is not a directory" d)) in
     let l = [dirs.components; dirs.validators; dirs.migrators;
              dirs.component_definitions; dirs.interface_definitions] in
     try
         List.iter check_dir l; Ok ()
     with Failure msg -> Error msg
