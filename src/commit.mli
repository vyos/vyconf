type status = {
  success : bool;
  out : string;
}

type node_data = {
    script_name: string;
    priority: int;
    tag_value: string option;
    arg_value: string option;
    path: string list;
    reply: status option;
} [@@deriving yojson]

type commit_data = {
    session_id: string;
    named_active : string option;
    named_proposed : string option;
    dry_run: bool;
    atomic: bool;
    background: bool;
    init: status option;
    node_list: node_data list;
} [@@deriving yojson]

val default_node_data : node_data

val default_commit_data : commit_data

val show_commit_data : Vyos1x.Config_tree.t -> Vyos1x.Config_tree.t -> string
