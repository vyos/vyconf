module CT = Vyos1x.Config_tree
module IC = Vyos1x.Internal.Make(CT)
module CC = Commitd_client.Commit
module CD = Vyos1x.Config_diff
module VT = Vyos1x.Vytree
module VL = Vyos1x.Vylist
module RT = Vyos1x.Reference_tree
module D = Directories
module FP = FilePath

exception Session_error of string

type cfg_op =
    | CfgSet of string list * string option * CT.value_behaviour
    | CfgDelete of string list * string	option
    [@@deriving yojson]

type world = {
    mutable running_config: CT.t;
    mutable reference_tree: RT.t;
    vyconf_config: Vyconf_config.t;
    dirs: Directories.t
}

type aux_op = {
    script_name: string;
    tag_value: string option;
    changeset: cfg_op list;
} [@@deriving yojson]


type session_data = {
    modified: bool;
    conf_mode: bool;
    changeset: cfg_op list;
    mutable aux_changeset: aux_op list;
    edit_level: string list;
    client_app: string;
    client_pid: int32;
    client_user: string;
    client_sudo_user: string;
} [@@deriving yojson]

let make _world client_app sudo_user user pid = {
    modified = false;
    conf_mode = false;
    changeset = [];
    aux_changeset = [];
    edit_level = [];
    client_app = client_app;
    client_user = user;
    client_sudo_user = sudo_user;
    client_pid = pid;
}

let string_of_op op =
    match op with
    | CfgSet (path, value, _) ->
        let path_str = Vyos1x.Util.string_of_list path in
        (match value with
         | None -> Printf.sprintf "set %s" path_str
         | Some v -> Printf.sprintf "set %s \"%s\"" path_str v)
    | CfgDelete (path, value) ->
        let path_str = Vyos1x.Util.string_of_list path in
        (match value with
         | None -> Printf.sprintf "delete %s" path_str
         | Some v -> Printf.sprintf "delete %s \"%s\"" path_str v)

let sprint_changeset ss =
    let ss = List.map (fun x -> aux_op_to_yojson x) ss in
    Yojson.Safe.to_string (`List ss)

let set_modified s =
    if s.modified = true then s
    else {s with modified = true}

let apply_cfg_op w op config =
    (* alert exn RT.refpath; RT.is_leaf; CT.set; CT.create_node; RT.set_tag_value:
        [Vytree.Empty_path] not possible as checked in set
        [Vytree.Nonexistent_path] not possible as checked in validate, in set
       alert exn CT.set; CT.create_node:
        [Config_tree.Useless_set] caught
       alert exn CT.set:
        [Config_tree.Duplicate_value] caught
       alert exn CT.delete; CT.prune_delete:
        [Vytree.Empty_path] not possible as checked in delete
        [Vytree.Nonexistent_path] not possible as checked in update_delete
     *)
    let result =
    match op with
    | CfgSet (path, value, value_behaviour) ->
        begin
        let rt = w.reference_tree in
        let refp = (RT.refpath[@alert "-exn"]) rt path in
        try
            let c =
            match ((RT.is_leaf[@alert "-exn"]) rt refp) with
            | true ->
                (CT.set[@alert "-exn"]) config path value value_behaviour
            | false ->
                (CT.create_node[@alert "-exn"]) config path
            in
            (RT.set_tag_data[@alert "-exn"]) rt c path
        with
        | CT.Useless_set | CT.Duplicate_value -> config
        end
    | CfgDelete (path, value) -> 
        begin
        try
            (CT.delete[@alert "-exn"]) config path value |>
            (fun c -> (CT.prune_delete[@alert "-exn"]) c path)
        with
        | VT.Nonexistent_path | CT.No_such_value -> config
        end
    in result

let rec apply_changes w changeset config =
    match changeset with
    | [] -> config
    | c :: cs -> apply_changes w cs (apply_cfg_op w c config)

let validate w _s path =
    (* alert exn RT.validate_path:
        [Reference_tree.Validation_error] caught
     *)
    try
        (RT.validate_path[@alert "-exn"]) D.(w.dirs.validators) w.reference_tree path
    with RT.Validation_error x -> raise (Session_error x)

let validate_tree w t =
    try
        let out = (RT.validate_tree[@alert "-exn"]) D.(w.dirs.validators) w.reference_tree t in
        match out with
        | "" -> ()
        | _ -> raise (Session_error out)
    with RT.Validation_error x -> raise (Session_error x)

let split_path w path =
    RT.split_path w.reference_tree path

let get_proposed_config w s =
    let c = w.running_config in
    apply_changes w (List.rev s.changeset) c

let update_set w _s changeset path =
    (* alert exn RT.refpath; RT.is_multi:
        [Vytree.Empty_path] checked or n/a in callers set, aux_set, get_changeset
        [Vytree.Nonexistent_path] checked or n/a in callers set, aux_set, get_changeset
     *)
    let path, value = split_path w path in
    let refpath = (RT.refpath[@alert "-exn"]) w.reference_tree path in
    let value_behaviour =
        if (RT.is_multi[@alert "-exn"]) w.reference_tree refpath
        then CT.AddValue else CT.ReplaceValue
    in
    let op = CfgSet (path, value, value_behaviour) in
    (op :: changeset)

let update_delete w s changeset path =
    (* alert exn VT.exists; CT.value_exists:
        [Vytree.Empty_path] checked or n/a in callers delete, aux_delete, get_changeset
       alert exn CT.value_exists:
        [Vytree.Nonexistent_path] checked by VT.exists
     *)
    let path, value = split_path w path in
    let proposed_config = get_proposed_config w s in
    if not ((VT.exists[@alert "-exn"]) proposed_config path)
    then raise (Session_error "Non-existent path")
    else
    let check_value =
        match value with
        | None -> true
        | Some v -> (CT.value_exists[@alert "-exn"]) proposed_config path v
    in
    if not check_value
    then raise (Session_error "Non-existent value")
    else
    let op = CfgDelete (path, value) in
    (op :: changeset)

let get_changeset w s lt rt =
    (* alert exn CD.diff_tree:
        [Config_diff.Incommensurable] not possible for base root
        [Config_diff.Empty_comparison] not possible for empty path
     *)
    let diff = (CD.diff_tree[@alert "-exn"]) [] lt rt in
    let add_tree = CT.get_subtree diff ["add"] in
    let del_tree = CT.get_subtree diff ["del"] in
    let add_changeset =
        List.fold_left (update_set w s) [] (CT.value_paths_of_tree add_tree)
    in
    let del_changeset =
        List.fold_left (update_delete w s) [] (CT.value_paths_of_tree del_tree)
    in
    add_changeset @ del_changeset

let set w s path =
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Path is empty")
    else
    let path_total = s.edit_level @ path in
    let _ = validate w s path_total in
    let changeset' = update_set w s s.changeset path_total in
    { s with changeset = changeset' }

let delete w s path =
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Path is empty")
    else
    let path_total = s.edit_level @ path in
    let changeset' = update_delete w s s.changeset path_total in
    { s with changeset = changeset' }

let aux_set w s path name tagval =
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Path is empty")
    else
    let _ = validate w s path in
    let aux = s.aux_changeset in
    let ident y =
        if (y.script_name <> name || y.tag_value <> tagval) then false
        else true
    in
    let op' = VL.find ident aux in
    let changeset' =
    match op' with
    | None ->
        update_set w s [] path
    | Some o ->
        update_set w s o.changeset path
    in
    let op =
    { script_name = name; tag_value = tagval; changeset = changeset' }
    in
    let aux_changeset' =
        (* Vylist.replace does not raise exception when force=true *)
        (VL.replace[@alert "-exn"]) ~force:true ident op aux
    in
    s.aux_changeset <- aux_changeset'

let aux_delete w s path name tagval =
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Path is empty")
    else
    let aux = s.aux_changeset in
    let ident y =
        if (y.script_name <> name || y.tag_value <> tagval) then false
        else true
    in
    let op' = VL.find ident aux in
    let changeset' =
    match op' with
    | None ->
        update_delete w s [] path
    | Some o ->
        update_delete w s o.changeset path
    in
    let op =
    { script_name = name; tag_value = tagval; changeset = changeset' }
    in
    let aux_changeset' =
        (* Vylist.replace does not raise exception when force=true *)
        (VL.replace[@alert "-exn"]) ~force:true ident op aux
    in
    s.aux_changeset <- aux_changeset'

let discard _w s =
    { s with changeset = []; }

let copy w s p1 p2 =
    if Vyos1x.Util.is_empty p1
    then raise (Session_error "Cannot copy an empty path")
    else
    if Vyos1x.Util.is_empty p2
    then raise (Session_error "Cannot copy to an empty path")
    else
    let p1_total = s.edit_level @ p1 in
    let p2_total = s.edit_level @ p2 in
    let ct = get_proposed_config w s in
    if not ((VT.exists[@alert "-exn"]) ct p1_total)
    then
    let p1_str = Vyos1x.Util.string_of_list p1_total in
    let out = Printf.sprintf "Configuration path \"%s\" does not exist" p1_str in
    raise (Session_error out)
    else
    let _ = validate w s p2_total in
    let ct' = (VT.copy[@alert "-exn"]) ct p1_total p2_total in
    let changeset' = get_changeset w s ct ct' in
    { s with changeset = changeset' @ s.changeset }

let rename w s p1 p2 =
    if Vyos1x.Util.is_empty p1
    then raise (Session_error "Cannot rename an empty path")
    else
    let p2_last =
      match Vyos1x.Util.get_last p2 with
      | None -> raise (Session_error "Cannot rename to an empty value")
      | Some v -> v
    in
    if (Vyos1x.Util.drop_last p1) <> (Vyos1x.Util.drop_last p2)
    then raise (Session_error "Cannot rename a node: paths are inconsistent")
    else
    let p1_total = s.edit_level @ p1 in
    let p2_total = s.edit_level @ p2 in
    let ct = get_proposed_config w s in
    if not ((VT.exists[@alert "-exn"]) ct p1_total)
    then
    let p1_str = Vyos1x.Util.string_of_list p1_total in
    let out = Printf.sprintf "Configuration path \"%s\" does not exist" p1_str in
    raise (Session_error out)
    else
    let _ = validate w s p2_total in
    let ct' = (VT.rename[@alert "-exn"]) ct p1_total p2_last in
    let changeset' = get_changeset w s ct ct' in
    { s with changeset = changeset' @ s.changeset }

let edit_env_str s =
    (* To maintain consistency with classic CLI, we return env variable for
       PS1 on changes to edit level.
     *)
    let ps1 =
    match s.edit_level with
    | [] ->
        "[edit]\\n\\u@\\H${VRF:+(vrf:$VRF)}${NETNS:+(ns:$NETNS)}# "
    | _ as p ->
        Printf.sprintf
        "[edit %s]\\n\\u@\\H${VRF:+(vrf:$VRF)}${NETNS:+(ns:$NETNS)}# "
        (Vyos1x.Util.string_of_list p)
    in
    Printf.sprintf "export PS1='%s';" ps1

let set_edit_level w s path =
    let current_level = s.edit_level in
    let new_level = current_level @ path in
    let result = RT.allowed_edit_level w.reference_tree new_level in
    match result with
    | Ok () ->
        let c = get_proposed_config w s in
        let s' =
            if not ((VT.exists[@alert "-exn"]) c path) then
                set w s path
            else s
        in
        let session = { s' with edit_level = new_level; } in
        session, (edit_env_str session)
    | Error msg ->
        raise (Session_error msg)

let set_edit_level_up w s =
    let current_level = s.edit_level in
    let new_level =
        if Vyos1x.Util.is_empty current_level then
            current_level
        else
        let up = Vyos1x.Util.drop_last current_level in
        match RT.allowed_edit_level w.reference_tree up with
        | Ok () -> up
        | Error _ -> (* tag_value *)
            Vyos1x.Util.drop_last up
    in
    let session = { s with edit_level = new_level; }
    in session, (edit_env_str session)

let get_edit_level _w s =
    Vyos1x.Util.string_of_list s.edit_level

let reset_edit_level _w s =
    let session = { s with edit_level = []; }
    in session, (edit_env_str session)

let edit_level_root _w s =
    Vyos1x.Util.is_empty s.edit_level

let session_changed w s =
    (* structural equality test requires consistent ordering, which is
     * practised, but may be unreliable; test actual difference
     *)
    (* alert exn CD.diff_tree:
        [Config_diff.Incommensurable] not possible for base root
        [Config_diff.Empty_comparison] not possible for empty path
     *)
    let c = get_proposed_config w s in
    let diff = (CD.diff_tree[@alert "-exn"]) [] w.running_config c in
    let add_tree = CT.get_subtree diff ["add"] in
    let del_tree = CT.get_subtree diff ["del"] in
    (del_tree <> CT.default) || (add_tree <> CT.default)

let load w s file cached =
    (* alert exn Internal.read_internal:
        [Internal.Read_error] caught
     *)
    let ct =
        if cached then
            try
                Ok ((IC.read_internal[@alert "-exn"]) file)
            with Vyos1x.Internal.Read_error e ->
                Error e
        else
            Vyos1x.Config_file.load_config file
    in
    match ct with
    | Error e -> raise (Session_error (Printf.sprintf "Error loading config: %s" e))
    | Ok config ->
        validate_tree w config;
        { s with changeset = get_changeset w s w.running_config config; }

let merge w s file destructive =
    (* alert exn CD.tree_merge:
        [Tree_alg.Incompatible_union] not possible for base root
        [Tree_alg.Nonexistent_child] not reachable
     *)
    let ct = Vyos1x.Config_file.load_config file in
    match ct with
    | Error e -> raise (Session_error (Printf.sprintf "Error loading config: %s" e))
    | Ok config ->
        let () = validate_tree w config in
        let proposed = get_proposed_config w s in
        let merged =
            (CD.tree_merge[@alert "-exn"]) ~destructive:destructive proposed config
        in
        { s with changeset = get_changeset w s w.running_config merged; }

let save w s file =
    let ct = w.running_config in
    let res = Vyos1x.Config_file.save_config ct file in
    match res with
    | Error e -> raise (Session_error (Printf.sprintf "Error saving config: %s" e))
    | Ok () -> s

let remove_file file =
    if Sys.file_exists file then Sys.remove file

let config_unsaved w s file id =
    let tmp_save = Printf.sprintf "/tmp/config.running_%s" id in
    let res =
        try
            let _ = save w s tmp_save in
            not (Vyos1x.Util.file_compare ~ignore_line_prefix:"//" tmp_save file)
        with Session_error _ -> true (* false positive on unlikely error *)
    in remove_file tmp_save; res

let reference_path_exists w _s path =
    RT.reference_path_exists w.reference_tree path

let get_path_type ?(legacy_format=false) w _s path =
    RT.get_path_type_str ~legacy_format w.reference_tree path

let get_completion_env ?(legacy_format=false) w s path =
    let op, path =
        match path with
        | [] -> raise (Session_error "Missing op and path")
        | h :: tl -> (h, tl)
    in
    let config = get_proposed_config w s in
    let path_total = s.edit_level @ path in
    let res =
        Vyos1x.Completion.get_completion_env_str ~legacy_format w.reference_tree config op path_total
    in
    match res with
    | Ok env -> env
    | Error e -> raise (Session_error e)

let write_running_cache w =
    (* alert exn Internal.write_internal:
        [Internal.Write_error] caught
     *)
    let vc = w.vyconf_config in
    try
        let () =
            (IC.write_internal_atomic[@alert "-exn"])
            w.running_config
            (FP.concat vc.session_dir vc.running_cache);
        in Ok ()
    with
        Vyos1x.Internal.Write_error msg ->
            let msg =
                Printf.sprintf "Write error caching running config: %s" msg
            in Error msg

let write_session_cache w config =
    (* alert exn Internal.write_internal:
        [Internal.Write_error] caught
     *)
    let vc = w.vyconf_config in
    try
        let () =
            (IC.write_internal[@alert "-exn"])
            config
            (FP.concat vc.session_dir vc.session_cache);
        in Ok ()
    with
        Vyos1x.Internal.Write_error msg ->
            let msg =
                Printf.sprintf "Write error caching session config: %s" msg
            in Error msg

let prepare_commit ?(dry_run=false) w s config id =
    let opt_running = write_running_cache w in
    let opt_session = write_session_cache w config in
    match opt_running, opt_session with
    | Ok (), Ok () ->
        Ok (CC.make_commit_data
            ~dry_run:dry_run
            w.reference_tree
            w.running_config
            config
            id
            s.client_pid
            s.client_sudo_user
            s.client_user)
    | Error msg, Ok () -> Error msg
    | Ok (), Error msg -> Error msg
    | Error msg1, Error msg2 -> Error (Printf.sprintf "%s\n %s" msg1 msg2)

let post_process_commit w s ((c_data: CC.commit_data), proposed_config) =
    let ident n v y =
        if (y.script_name <> n || y.tag_value <> v) then false
        else true
    in
    let func (running, proposed) (n_data: CC.node_data) =
        match n_data.reply with
        | None -> (running, proposed)
        | Some reply ->
            match reply.success with
            | false -> (running, proposed)
            | true ->
                begin
                let post =
                    VL.find
                    (ident n_data.script_name n_data.tag_value)
                    s.aux_changeset
                in
                match post with
                | None -> (running, proposed)
                | Some p ->
                    (apply_changes w p.changeset running, apply_changes w p.changeset proposed)
                end
    in
    List.fold_left func (c_data.config_result, proposed_config) c_data.node_list

let get_config w s id =
    (* alert exn Internal.write_internal:
        [Internal.Write_error] caught
     *)
    let at = w.running_config in
    let wt = get_proposed_config w s in
    let vc = w.vyconf_config in
    let running_cache = Printf.sprintf "%s_%s" vc.running_cache id in
    let session_cache = Printf.sprintf "%s_%s" vc.session_cache id in
    let () =
        try
            (IC.write_internal[@alert "-exn"]) at (FP.concat vc.session_dir running_cache)
        with
            Vyos1x.Internal.Write_error msg -> raise (Session_error msg)
    in
    let () =
        try
            (IC.write_internal[@alert "-exn"]) wt (FP.concat vc.session_dir session_cache)
        with
            Vyos1x.Internal.Write_error msg -> raise (Session_error msg)
    in id

let cleanup_config w id =
    let vc = w.vyconf_config in
    let running_cache = Printf.sprintf "%s_%s" vc.running_cache id in
    let session_cache = Printf.sprintf "%s_%s" vc.session_cache id in
    remove_file (FP.concat vc.session_dir running_cache);
    remove_file (FP.concat vc.session_dir session_cache)

let get_value w s path =
    (* alert exn VT.exists:
        [Vytree.Empty_path] checked
       alert exn RT.repath; RT.is_leaf; RT.is_multi; RT.is_valueless:
        [Vytree.Empty_path] checked
        [Vytree.Nonexistent_path] checked by VT.exists
       alert exn CT.get_value:
        [Vytree.Empty_path] checked
        [Vytree.Nonexistent_path] checked by VT.exists
        [Config_tree.Node_has_no_value] checked by RT.is_valueless
     *)
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Config path is empty")
    else let c = get_proposed_config w s in
    if not ((VT.exists[@alert "-exn"]) c path) then
        raise (Session_error ("Config path does not exist"))
    else let refpath = (RT.refpath[@alert "-exn"]) w.reference_tree path in
    if not ((RT.is_leaf[@alert "-exn"]) w.reference_tree refpath) then
        raise (Session_error "Cannot get a value of a non-leaf node")
    else if ((RT.is_multi[@alert "-exn"]) w.reference_tree refpath) then
        raise (Session_error "This node can have more than one value")
    else if ((RT.is_valueless[@alert "-exn"]) w.reference_tree refpath) then
        raise (Session_error "This node is valueless")
    else (CT.get_value[@alert "-exn"]) c path

let get_values w s path =
    (* alert exn VT.exists:
        [Vytree.Empty_path] checked
       alert exn RT.repath; RT.is_leaf; RT.is_multi; RT.is_valueless; CT.get_values:
        [Vytree.Empty_path] checked
        [Vytree.Nonexistent_path] checked by VT.exists
     *)
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Config path is empty")
    else let c = get_proposed_config w s in
    if not ((VT.exists[@alert "-exn"]) c path) then
        raise (Session_error ("Config path does not exist"))
    else let refpath = (RT.refpath[@alert "-exn"]) w.reference_tree path in
    if not ((RT.is_leaf[@alert "-exn"]) w.reference_tree refpath) then
        raise (Session_error "Cannot get a value of a non-leaf node")
    else if not ((RT.is_multi[@alert "-exn"]) w.reference_tree refpath) then
        raise (Session_error "This node can have only one value")
    else (CT.get_values[@alert "-exn"]) c path

let list_children w s path =
    (* alert exn VT.exists:
        [Vytree.Empty_path] checked
       alert exn RT.repath; RT.is_leaf; VT.children_of_path:
        [Vytree.Empty_path] checked
        [Vytree.Nonexistent_path] checked by VT.exists
     *)
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Config path is empty")
    else let c = get_proposed_config w s in
    if not ((VT.exists[@alert "-exn"]) c path) then
        raise (Session_error ("Config path does not exist"))
    else let refpath = (RT.refpath[@alert "-exn"]) w.reference_tree path in
    if ((RT.is_leaf[@alert "-exn"]) w.reference_tree refpath) then
        raise (Session_error "Cannot list children of a leaf node")
    else (VT.children_of_path[@alert "-exn"]) c path

let exists w s path =
    (* alert exn VT.exists:
        [Vytree.Empty_path] checked
     *)
    if Vyos1x.Util.is_empty path
    then raise (Session_error "Path is empty")
    else let c = get_proposed_config w s in
    (VT.exists[@alert "-exn"]) c path

let show_config w s path =
    let path_total = s.edit_level @ path in
    let path_show =
        match RT.get_path_type w.reference_tree path_total with
        | `Leaf_value -> Vyos1x.Util.drop_last path_total
        | _ -> path_total
    in
    let proposed_config = get_proposed_config w s in
    if not (Vyos1x.Util.is_empty path_show) &&
       not ((VT.exists[@alert "-exn"]) proposed_config path_show)
    then raise (Session_error "Path does not exist")
    else
    let res =
        (CD.diff_show[@alert "-exn"])
        w.reference_tree
        path_show
        w.running_config
        proposed_config
    in res
