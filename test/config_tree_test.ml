[@@@ocaml.warning "-27"]

open OUnit2

module VT = Vyos1x.Vytree
module CT = Vyos1x.Config_tree
module RT = Vyos1x.Reference_tree

(* Setting a value of a node that doesn't exist should create the node *)
let test_set_create_node test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "baz") CT.ReplaceValue in
    let values = CT.get_values node path in
    assert_equal values ["baz"]

(* Setting a value with AddValue behaviour should append the new value *)
let test_set_add_value test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "baz") CT.AddValue in
    let node = CT.set node path (Some "quux") CT.AddValue in
    let values = CT.get_values node path in
    assert_equal values ["baz"; "quux"]

(* Setting a value with ReplaceValue behaviour should replace the value *)
let test_set_replace_value test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "baz") CT.ReplaceValue in
    let node = CT.set node path (Some "quux") CT.ReplaceValue in
    let values = CT.get_values node path in
    assert_equal values ["quux"]

(* Creating a node without a value should work *)
let test_create_valueless_node test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    assert_equal (CT.get_values node path) []

(* Deleting just one of many values should keep all other values intact *)
let test_delete_just_value test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "baz") CT.AddValue in
    let node = CT.set node path (Some "quux") CT.AddValue in
    let node = CT.delete node path (Some "quux") in
    assert_equal (CT.get_values node path) ["baz"]

(* Deleting the last value should delete the whole leaf *)
let test_delete_last_value test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "baz") CT.AddValue in
    let node = CT.delete node path (Some "baz") in
    assert_equal ((not (VT.exists node path)) && (VT.exists node ["foo"])) true

(* Deleting a non-leaf node should delete the whole subtree *)
let test_delete_subtree test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "baz") CT.AddValue in
    let node = CT.delete node ["foo"] None in
    assert_equal (VT.list_children node) []

(* Setting a node comment for an existent node should work *)
let test_set_comment test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    let node = CT.set_comment node path (Some "comment") in
    assert_equal (CT.get_comment node path) (Some "comment")

(**** Properties ephemeral and inactive: not yet implemented *)
(*
(* Creating a node without a value should default inactive and ephemeral to false *)
let test_valueless_node_inactive_ephemeral test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    assert_equal ((not (CT.is_inactive node path)) && (not (CT.is_ephemeral node path))) true

(* Setting a node inactive should work *)
let test_set_inactive test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    let node = CT.set_inactive node path (true) in
    assert_equal (CT.is_inactive node path) true

(* Setting a node ephemeral should work *)
let test_set_ephemeral test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    let node = CT.set_ephemeral node path (true) in
    assert_equal (CT.is_ephemeral node path) true
*)


(*** Refactoring test setup *)
let set ?(how=CT.AddValue) path value node = CT.set node path value how

let config_tree_of_path path = CT.make "root" |> set path None

let set_in_config_tree ~how ?(path=[]) ?value =
    let node = config_tree_of_path path in
    how node path value

let toggle_in_config_tree ~how ?(path=[]) ?(value=false) =
    let node = config_tree_of_path path in
    how node path value

let load_reftree test_ctxt =
    let file_name = "interface_definition_sample.xml" in
    let r = VT.make RT.default_data "root" in
    RT.load_from_xml r (in_testdata_dir test_ctxt [file_name])

let foobar = ["foo"; "bar"]

(*** Rendering tests *)

(**** Standalone rendering *)
let test_render_nested_empty_with_comment test_ctxt =
    let rendered = CT.render_config @@
        set_in_config_tree
            ~how:CT.set_comment ~value:"comment"
            ~path:foobar
    in
    assert_equal (String.trim rendered)
"foo {
    /* comment */
    bar
}"

let test_render_at_level test_ctxt =
    let path = ["foo"; "bar"; "baz"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "quux") CT.AddValue in
    let rendered = CT.render_at_level node ["foo"] in
    assert_equal (String.trim rendered)
"bar {
    baz \"quux\"
}"

let test_render_at_level_top test_ctxt =
    let path1 = ["foo"; "bar"] in
    let path2 = ["baz"; "quux"] in
    let node = CT.make "root" in
    let node = CT.set node path1 (Some "quuux") CT.AddValue in
    let node = CT.set node path2 (Some "xyzzy") CT.AddValue in
    let rendered = CT.render_at_level node [] in
    assert_equal (String.trim rendered)
"baz {
    quux \"xyzzy\"
}
foo {
    bar \"quuux\"
}"

(**** Reftree-based rendering: not yet implemented *)
(*
let test_render_rt_tag_node test_ctxt =
    let reftree = load_reftree test_ctxt in
    let path = ["system"; "login"; "user"; "full-name"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "name here") CT.AddValue in
    let rendered_curly_config = CT.render_config ~reftree:(Some reftree) node in
    let desired_rendered_form =
"root {
    system {
        login {
             user full-name \"name here\";
        }
    }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form

let test_render_rt_unspecified_node test_ctxt =
    let reftree = load_reftree test_ctxt in
    let path = ["system"; "login"; "user"; "unspecified_node"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "name here") CT.AddValue in
    let rendered_curly_config = CT.render ~reftree:(Some reftree) node in
    let desired_rendered_form =
"root {
    system {
        login {
             user unspecified_node \"name here\";
        }
    }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form
*)
let suite =
    "VyConf config tree tests" >::: [
        "test_set_create_node" >:: test_set_create_node;
        "test_set_add_value" >:: test_set_add_value;
        "test_set_replace_value" >:: test_set_replace_value;
        "test_create_valueless_node" >:: test_create_valueless_node;
        "test_delete_just_value" >:: test_delete_just_value;
        "test_delete_last_value" >:: test_delete_last_value;
        "test_delete_subtree" >:: test_delete_subtree;
        "test_set_comment" >:: test_set_comment;
        "test_render_nested_empty_with_comment" >:: test_render_nested_empty_with_comment;
        "test_render_at_level" >:: test_render_at_level;
        "test_render_at_level_top" >:: test_render_at_level_top;
    ]

let () =
    run_test_tt_main suite
