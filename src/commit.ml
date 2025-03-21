module VT = Vyos1x.Vytree
module CT = Vyos1x.Config_tree
module CD = Vyos1x.Config_diff
module RT = Vyos1x.Reference_tree

type tree_source = DELETE | ADD

let tree_source_to_yojson = function
    | DELETE -> `String "DELETE"
    | ADD -> `String "ADD"

type status = {
  success : bool;
  out : string;
} [@@deriving to_yojson]

type node_data = {
    script_name: string;
    priority: int;
    tag_value: string option;
    arg_value: string option;
    path: string list;
    source: tree_source;
    reply: status option;
} [@@deriving to_yojson]


let default_node_data = {
    script_name = "";
    priority = 0;
    tag_value = None;
    arg_value = None;
    path = [];
    source = ADD;
    reply = Some { success = false; out = ""; };
}

type commit_data = {
    session_id: string;
    named_active : string option;
    named_proposed : string option;
    dry_run: bool;
    atomic: bool;
    background: bool;
    init: status option;
    node_list: node_data list;
} [@@deriving to_yojson]

let default_commit_data = {
    session_id = "";
    named_active = None;
    named_proposed = None;
    dry_run = false;
    atomic = false;
    background = false;
    init = Some { success = false; out = ""; };
    node_list = [];
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
    type t = node_data
    let compare a b =
        match compare a.priority b.priority with
        | 0 -> lex_order a b
        | _ as c -> c
end
module CS = Set.Make(CI)

let owner_args_from_data p o =
    let oa = Pcre.split o in
    let owner = FilePath.basename (List.nth oa 0) in
    if List.length oa < 2 then owner, None
    else
    let var = List.nth oa 1 in
    let res = Pcre.extract_all ~pat:"\\.\\./" var in
    let var_pos = Array.length res in
    let arg_value = Vyos1x.Util.get_last_n p var_pos
    in owner, arg_value

let add_tag_instance cd cs tv =
    CS.add { cd with tag_value = Some tv; } cs

let get_node_data rt ct src (path, cs') t =
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
    match owner with
    | None -> (path, cs')
    | Some owner_str ->
    let (own, arg) = owner_args_from_data rpath owner_str in
    let c_data = { default_node_data with
                   script_name = own;
                   priority = priority;
                   arg_value = arg;
                   path = rpath;
                   source = src; }
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

let get_commit_set rt ct src =
    snd (VT.fold_tree_with_path (get_node_data rt ct src) ([], CS.empty) ct)

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
    let cs_del' = get_commit_set rt del_tree DELETE in
    let cs_add' = get_commit_set rt add_tree ADD in
    let cs_del, cs_add = legacy_order del_tree cs_del' cs_add' in
    List.rev (CS.elements cs_del), CS.elements cs_add

let commit_store c_data =
    let out =
        let func acc nd =
            match nd.reply with
            | None -> acc ^ "\n"
            | Some r ->
                match r.success with
                | true -> acc ^ "\n"
                | false -> acc ^ "\n" ^ r.out
        in List.fold_left func "" c_data.node_list
    in print_endline out
