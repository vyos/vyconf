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
  | c = COMMENT { Some c }

value:
  | v = STRING
    { v }
  | v = IDENTIFIER
    { v }
;

values:
  | v = value { [v] }
  | LEFT_BRACKET; vs = separated_nonempty_list(SEMI, value); RIGHT_BRACKET
    { vs }
;

leaf_node:
  | comment = opt_comment; name = IDENTIFIER; values = values; SEMI
    { Vytree.make_full {default_data with values=values; comment=comment} name []}
;

node:
  | comment = opt_comment; name = IDENTIFIER; LEFT_BRACE; children = list(node_content); RIGHT_BRACE
    { let node = Vytree.make_full {default_data with comment=comment} name [] in List.fold_left Vytree.adopt node children  }
;

node_content: n = node { n } | n = leaf_node { n };

%public config:
    ns = list(node);  EOF
  {
    let root = make "root" in List.fold_left Vytree.adopt root ns
  }
;
