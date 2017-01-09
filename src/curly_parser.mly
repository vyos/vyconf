%{
    open Config_tree
%}

%token <string> IDENTIFIER
%token <string> STRING
%token <string> COMMENT
%token LEFT_BRACE
%token RIGHT_BRACE
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token SEMI
%token EOF

%start <Config_tree.t> config
%%

opt_comment:
  | (* empty *) { None }
  | c = COMMENT { Some (String.trim c) }

value:
  | v = STRING
    { v }
  | v = IDENTIFIER
    { v }
;

values:
  | v = value { [v] }
  | LEFT_BRACKET; vs = separated_nonempty_list(SEMI, value); RIGHT_BRACKET
    { (List.rev vs) }
;

leaf_node:
  | comment = opt_comment; name = IDENTIFIER; values = values; SEMI
    { Vytree.make_full {default_data with values=(List.rev values); comment=comment} name []}
  | comment = opt_comment; name = IDENTIFIER; SEMI (* valueless node *)
    { Vytree.make_full {default_data with comment=comment} name [] }
;

node:
  | comment = opt_comment; name = IDENTIFIER; LEFT_BRACE; children = list(node_content); RIGHT_BRACE
    {
        let node = Vytree.make_full {default_data with comment=comment} name [] in
        List.fold_left Vytree.adopt node (List.rev children) |> Vytree.merge_children
    }
;

tag_node:
  | comment = opt_comment; name = IDENTIFIER; tag = IDENTIFIER; LEFT_BRACE; children = list(node_content); RIGHT_BRACE
  {
      let outer_node = Vytree.make_full default_data name [] in
      let inner_node = Vytree.make_full {default_data with comment=comment} tag [] in
      let inner_node = List.fold_left Vytree.adopt inner_node (List.rev children) |> Vytree.merge_children
      in Vytree.adopt outer_node inner_node
  }

node_content: n = node { n } | n = leaf_node { n } | n = tag_node { n };

%public config:
    ns = list(node);  EOF
  {
    let root = make "root" in List.fold_left Vytree.adopt root (List.rev ns)
  }
;
