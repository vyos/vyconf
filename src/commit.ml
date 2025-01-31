module VT = Vyos1x.Vytree
module CT = Vyos1x.Config_tree
module RT = Vyos1x.Reference_tree

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
