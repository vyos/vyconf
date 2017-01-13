open OUnit2

module CT = Config_tree

let config_empty = ""

let config_trivial = "foo { }"

let config_nested = "foo { bar { } baz { } }"

let config_leaf_top_level = "foo bar;"

let config_tag_top_level = "foo bar { baz quux; }"

let config_with_leaf = "foo { bar baz; }"
let config_with_leaf_url_unquoted = "foo { bar http://www2.example.org/foo; }"
let config_with_leaf_value_quoted = "foo { bar \"foo bar\"; }"
let config_with_leaf_value_single_quoted = "foo { bar \'foo bar\'; }"
let config_with_leaf_valueless = "foo { bar; }"

(* XXX: naive use of Menhir's separated_list doesn't allow [baz; xyzzy;],
        perhaps we should support it too *)
let config_with_multi = "foo { bar [baz; xyzzy]; }"

let config_with_tag = "foo { bar baz { quux xyzzy; } bar qwerty { quux foobar; } }"
let config_with_tag_nonalpha = "foo { bar baz0.99 { } bar baz1-8 { } }"

let config_with_comment = "foo { /* comment */ bar { } }"
let config_with_leaf_node_comment = "foo { /* comment */ bar baz; }"
let config_with_tag_node_comment = "foo { /* comment */ bar baz { } }"

let config_with_duplicate_node = "foo { bar { baz {} } bar { baz {} } }"
let config_with_duplicate_tag_node = "foo { bar baz0 { } bar baz0 { } }"
let config_with_duplicate_leaf_node = "foo { bar baz; bar quux; }"

let config_with_inactive_node = "#INACTIVE foo { bar baz; }"
let config_with_inactive_leaf_node = "foo { #INACTIVE bar baz; quux xyzzy; }"
let config_with_inactive_tag_node = "foo { #INACTIVE bar baz { quux xyzzy; } }"

let config_with_ephemeral_node = "#EPHEMERAL foo { } bar { }"
let config_with_ephemeral_leaf_node = "foo { #EPHEMERAL bar baz; quux xyzzy; } bar { }"
let config_with_ephemeral_tag_node = "foo { #EPHEMERAL bar baz { #INACTIVE quux xyzzy; } }"

let config_with_inactive_and_ephemeral_node = "#INACTIVE #EPHEMERAL foo { bar { } }"
let config_with_inactive_node_and_comment = "/* comment */ #INACTIVE #EPHEMERAL foo { }"

let parse s = Curly_parser.config Curly_lexer.token (Lexing.from_string s)

(* Empty config is considered valid, creates just the root node *)
let test_parse_empty test_ctxt =
    let config = parse config_empty in
    assert_equal (Vytree.list_children config) []

(* A config with just an empty node is considered valid too. Not sure if it should! *)
let test_parse_trivial test_ctxt =
    let config = parse config_trivial in
    assert_equal (Vytree.list_children config) ["foo"]

(* A config with nested nodes is parser correctly *)
let test_parse_nested test_ctxt =
    let config = parse config_nested in 
    assert_equal (Vytree.get config ["foo"] |> Vytree.list_children ) ["bar"; "baz"]

(* Leaf nodes are parsed correctly *)
let test_parse_with_leaf test_ctxt =
    let config = parse config_with_leaf in
    assert_equal (CT.get_value config ["foo"; "bar"]) "baz"

(* Leaf nodes with non-alphanumeric characters in values are parsed correctly *)
let test_parse_with_leaf_url_unquoted test_ctxt =
    let config = parse config_with_leaf_url_unquoted in
    assert_equal (CT.get_value config ["foo"; "bar"]) "http://www2.example.org/foo"

(* Leaf nodes with quoted values are parsed correctly *)
let test_parse_with_leaf_value_quoted test_ctxt =
    let config = parse config_with_leaf_value_quoted in
    assert_equal (CT.get_value config ["foo"; "bar"]) "foo bar"

(* Leaf nodes with single quoted values are parsed correctly *)
let test_parse_with_leaf_value_single_quoted test_ctxt =
    let config = parse config_with_leaf_value_single_quoted in
    assert_equal (CT.get_value config ["foo"; "bar"]) "foo bar"

(* Valueless leaf nodes work *)
let test_parse_with_leaf_valueless test_ctxt =
    let config = parse config_with_leaf_valueless in
    assert_equal (Vytree.get config ["foo"] |> Vytree.list_children) ["bar"]

(* Top level leaf nodes are not allowed *)
let test_parse_top_level_leaf_node test_ctxt =
    assert_raises Curly_parser.Error (fun () -> parse config_leaf_top_level)

(* Top level tag nodes are not allowed *)
let test_parse_top_level_tag_node test_ctxt =
    assert_raises Curly_parser.Error (fun () -> parse config_tag_top_level)

(* Nodes with multiple values are handled correctly *)
let test_parse_with_multi test_ctxt =
    let config = parse config_with_multi in
    assert_equal (CT.get_values config ["foo"; "bar"]) ["baz"; "xyzzy"]

(* Comments should work *)
let test_parse_with_comment test_ctxt =
    let config = parse config_with_comment in
    assert_equal (CT.get_comment config ["foo"; "bar"]) (Some (String.trim "comment"))

(* Comments in leaf nodes should work *)
let test_parse_with_leaf_node_comment test_ctxt =
    let config = parse config_with_leaf_node_comment in
    assert_equal (CT.get_comment config ["foo"; "bar"]) (Some (String.trim "comment"))

(* Comments in tag nodes should work *)
let test_parse_with_tag_node_comment test_ctxt =
    let config = parse config_with_tag_node_comment in
    assert_equal (CT.get_comment config ["foo"; "bar"; "baz"]) (Some (String.trim "comment"))

(* Tag nodes are parsed correctly *)
let test_parse_with_tag test_ctxt =
    let config = parse config_with_tag in
    assert_equal (Vytree.get config ["foo"; "bar"] |> Vytree.list_children) ["baz"; "qwerty"];
    assert_equal (CT.get_value config ["foo"; "bar"; "baz"; "quux"]) "xyzzy";
    assert_equal (CT.get_value config ["foo"; "bar"; "qwerty"; "quux"]) "foobar"

(* Non-alphanumeric characters are allowed in tag nodes *)
let test_parse_with_tag_nonalpha test_ctxt =
    let config = parse config_with_tag_nonalpha in
    assert_equal (Vytree.get config ["foo"; "bar"] |> Vytree.list_children) ["baz0.99"; "baz1-8"]

(* Normal nodes with duplicate children are detected *)
let test_parse_node_duplicate_child test_ctxt =
    try ignore @@ parse config_with_duplicate_node; assert_failure "Duplicated node child didn't cause errors"
    with (Failure _) -> ()

(* Tag nodes with duplicate children are detected *)
let test_parse_tag_node_duplicate_child test_ctxt =
    try ignore @@ parse config_with_duplicate_tag_node; assert_failure "Duplicated tag node child didn't cause errors"
    with (Failure _) -> ()

(* If there are duplicate leaf nodes, values of the next ones are merged into the first one,
   the rest of the data is lost *)
let test_parse_duplicate_leaf_node test_ctxt =
    let config = parse config_with_duplicate_leaf_node in
    assert_equal (CT.get_values config ["foo"; "bar"]) ["baz"; "quux"]

(* Inactive nodes are parsed correctly *)
let test_parse_inactive_node test_ctxt =
    let config = parse config_with_inactive_node in
    assert_equal (CT.is_inactive config ["foo"]) true

(* Inactive leaf nodes are parsed correctly *)
let test_parse_inactive_leaf_node test_ctxt =
    let config = parse config_with_inactive_leaf_node in
    assert_equal (CT.is_inactive config ["foo"; "bar"]) true

(* Inactive leaf nodes are parsed correctly *)
let test_parse_inactive_tag_node test_ctxt =
    let config = parse config_with_inactive_tag_node in
    assert_equal (CT.is_inactive config ["foo"; "bar"; "baz"]) true

(* Normally ephemeral nodes shouldn't appear in config files, since it's the whole
   point of ephemeral nodes that they are ignored when saving the config,
   but they are a part of the format so we get to parse them.
   Besides, HA scripts may want to use load or merge instead of executing set commands *)

(* Ephemeral nodes are parsed correctly *)
let test_parse_ephemeral_node test_ctxt =
    let config = parse config_with_ephemeral_node in
    assert_equal (CT.is_ephemeral config ["foo"]) true

(* Ephemeral leaf nodes are parsed correctly *)
let test_parse_ephemeral_leaf_node test_ctxt =
    let config = parse config_with_ephemeral_leaf_node in
    assert_equal (CT.is_ephemeral config ["foo"; "bar"]) true

(* Ephemeral leaf nodes are parsed correctly *)
let test_parse_ephemeral_tag_node test_ctxt =
    let config = parse config_with_ephemeral_tag_node in
    assert_equal (CT.is_ephemeral config ["foo"; "bar"; "baz"]) true

(* Unusual but not impossible: a node that is both inactive and ephemeral *)
let test_parse_inactive_and_ephemeral_node test_ctxt =
    let config = parse config_with_inactive_and_ephemeral_node in
    assert_equal (CT.is_ephemeral config ["foo"]) true;
    assert_equal (CT.is_inactive config ["foo"]) true

(* Comments and ephemeral/inactive properties mix well *)
let test_parse_inactive_node_and_comment test_ctxt =
    let config = parse config_with_inactive_node_and_comment in
    assert_equal (CT.is_ephemeral config ["foo"]) true;
    assert_equal (CT.is_inactive config ["foo"]) true;
    assert_equal (CT.get_comment config ["foo"]) (Some "comment")

let suite =
    "VyConf curly config parser tests" >::: [
        "test_make_node" >:: test_parse_empty;
        "test_parse_trivial" >:: test_parse_trivial;
        "test_parse_nested" >:: test_parse_nested;
        "test_parse_with_leaf" >:: test_parse_with_leaf;
        "test_parse_with_leaf_url_unquoted" >:: test_parse_with_leaf_url_unquoted;
        "test_parse_with_leaf_value_quoted" >:: test_parse_with_leaf_value_quoted;
        "test_parse_with_leaf_value_single_quoted" >:: test_parse_with_leaf_value_single_quoted;
        "test_parse_with_leaf_valueless" >:: test_parse_with_leaf_valueless;
        "test_parse_top_level_leaf_node" >:: test_parse_top_level_leaf_node;
        "test_parse_top_level_tag_node" >:: test_parse_top_level_tag_node;
        "test_parse_with_multi" >:: test_parse_with_multi;
        "test_parse_with_tag" >:: test_parse_with_tag;
        "test_parse_with_tag_nonalpha" >:: test_parse_with_tag_nonalpha;
        "test_parse_with_comment" >:: test_parse_with_comment;
        "test_parse_with_leaf_node_comment" >:: test_parse_with_leaf_node_comment;
        "test_parse_with_tag_node_comment" >:: test_parse_with_tag_node_comment;
        "test_parse_node_duplicate_child" >:: test_parse_node_duplicate_child;
        "test_parse_tag_node_duplicate_child" >:: test_parse_tag_node_duplicate_child;
        "test_parse_duplicate_leaf_node" >:: test_parse_duplicate_leaf_node;
        "test_parse_inactive_node" >:: test_parse_inactive_node;
        "test_parse_inactive_leaf_node" >:: test_parse_inactive_leaf_node;
        "test_parse_inactive_tag_node" >:: test_parse_inactive_tag_node;
        "test_parse_ephemeral_node" >:: test_parse_ephemeral_node;
        "test_parse_ephemeral_leaf_node" >:: test_parse_ephemeral_leaf_node;
        "test_parse_ephemeral_tag_node" >:: test_parse_ephemeral_tag_node;
        "test_parse_inactive_and_ephemeral_node" >:: test_parse_inactive_and_ephemeral_node;
        "test_parse_inactive_node_and_comment" >:: test_parse_inactive_node_and_comment;
    ]

let () =
  run_test_tt_main suite

