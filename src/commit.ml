module VT = Vyos1x.Vytree
module CT = Vyos1x.Config_tree
module CD = Vyos1x.Config_diff
module RT = Vyos1x.Reference_tree
module FP = FilePath

type commit_data = {
    script: string option;
    priority: int;
    tag_value: string option;
    arg_value: string option;
    path: string list;
} [@@deriving yojson]


let default_commit_data = {
    script = None;
    priority = 0;
    tag_value = None;
    arg_value = None;
    path = [];
}

let lex_order c1 c2 =
    let c = Vyos1x.Util.lex_order c1.path c2.path in
    match c with
    | 0 ->
        begin
            match c1.tag_value, c2.tag_value with
            | Some t1, Some t2 -> Vyos1x.Util.lexical_numeric_compare t1 t2
            | _ -> 0
        end
    | _ as a -> a

module CI = struct
    type t = commit_data
    let compare a b =
        match compare a.priority b.priority with
        | 0 -> lex_order a b
        | _ as c -> c
end
module CS = Set.Make(CI)

let owner_args_from_data p s =
    match s with
    | None -> None, None
    | Some o ->
    let oa = Pcre.split o in
    let owner = FilePath.basename (List.nth oa 0) in
    if List.length oa < 2 then Some owner, None
    else
    let var = List.nth oa 1 in
    let res = Pcre.extract_all ~pat:"\\.\\./" var in
    let var_pos = Array.length res in
    let arg_value = Vyos1x.Util.get_last_n p var_pos
    in Some owner, arg_value

let add_tag_instance cd cs tv =
    CS.add { cd with tag_value = Some tv; } cs

let get_commit_data rt ct (path, cs') t =
    if Vyos1x.Util.is_empty path then
        (path, cs')
    else
    if (VT.name_of_node t) = "" then
        (path, cs')
    else
    let rpath = List.rev path in
    (* the following is critical to avoid redundant calculations for owner
       of a tag node, quadratic in the number of tag node values *)
    if CT.is_tag_value ct rpath then
        (path, cs')
    else
    let rt_path = RT.refpath rt rpath in
    let priority =
        match RT.get_priority rt rt_path with
        | None -> 0
        | Some s -> int_of_string s
    in
    let owner = RT.get_owner rt rt_path in
    if  owner = None then (path, cs')
    else
    let (own, arg) = owner_args_from_data rpath owner in
    let c_data = { default_commit_data with
                   script = own;
                   priority = priority;
                   arg_value = arg;
                   path = rpath; }
    in
    let tag_values =
        match RT.is_tag rt rt_path with
        | false -> []
        | true -> VT.list_children t
    in
    let cs =
        match tag_values with
        | [] -> CS.add c_data cs'
        | _ -> List.fold_left (add_tag_instance c_data) cs' tag_values
    in (path, cs)

let get_commit_set rt ct =
    snd (VT.fold_tree_with_path (get_commit_data rt ct) ([], CS.empty) ct)

(* for initial consistency with the legacy ordering of delete and add
   queues, enforce the following subtlety: if a path in the delete tree is
   an owner node, or the tag value thereof, insert in the delete queue; if
   the path is in a subtree, however, insert in the add queue - cf. T5492
*)
let legacy_order del_t a b =
    let shift c_data (c_del, c_add) =
        let path =
            match c_data.tag_value with
            | None -> c_data.path
            | Some v -> c_data.path @ [v]
        in
        match VT.is_terminal_path del_t path with
        | false -> CS.remove c_data c_del, CS.add c_data c_add
        | true -> c_del, c_add
    in
    CS.fold shift a (a, b)

let calculate_priority_lists rt at wt =
    let diff = CD.diff_tree [] at wt in
    let del_tree = CD.get_tagged_delete_tree diff in
    let add_tree = CT.get_subtree diff ["add"] in
    let cs_del' = get_commit_set rt del_tree in
    let cs_add' = get_commit_set rt add_tree in
    let cs_del, cs_add = legacy_order del_tree cs_del' cs_add' in
    List.rev (CS.elements cs_del), CS.elements cs_add

let show_commit_data at wt =
    let vc =
        Startup.load_daemon_config Defaults.defaults.config_file in
    let rt_opt =
        Startup.read_reference_tree (FP.concat vc.reftree_dir vc.reference_tree)
    in
    match rt_opt with
    | Error msg -> msg
    | Ok rt ->
        let del_list, add_list =
            calculate_priority_lists rt at wt
        in
        let sprint_commit_data acc s =
            acc ^ "\n" ^ (commit_data_to_yojson s |> Yojson.Safe.to_string)
        in
        let del_out = List.fold_left sprint_commit_data "" del_list in
        let add_out = List.fold_left sprint_commit_data "" add_list in
        del_out ^ "\n" ^ add_out
