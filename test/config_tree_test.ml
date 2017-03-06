open OUnit2

module VT = Vytree
module CT = Config_tree

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

let test_render_nested_empty_with_comment test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    let node = CT.set_comment node path (Some "comment") in
    let rendered_curly_config = CT.render node in
    let desired_rendered_form =
"root {
    foo {
        /*comment*/
        bar { }
    }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form

let test_render_ephemeral_hidden teset_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    let node = CT.set_ephemeral node path (true) in
    let rendered_curly_config = CT.render node in
    let desired_rendered_form =
"root {
    foo { }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form

let test_render_ephemeral_shown teset_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path None CT.AddValue in
    let node = CT.set_ephemeral node path (true) in
    let rendered_curly_config = CT.render ~showephemeral:true node in
    let desired_rendered_form =
"root {
    foo {
        #EPHEMERAL bar { }
    }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form

let load_reftree test_ctxt =
    let file_name = "interface_definition_sample.xml" in
    let r = Vytree.make Reference_tree.default_data "root" in
    Reference_tree.load_from_xml r (in_testdata_dir test_ctxt [file_name])

let test_render_rt_tag_node test_ctxt =
    let reftree = load_reftree test_ctxt in
    let path = ["system"; "login"; "user"; "full-name"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "name here") CT.AddValue in
    let rendered_curly_config = CT.render ~reftree node in
    let desired_rendered_form =
"root {
    system {
        login {
            user {
                user full-name \"name here\";
            }
        }
    }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form

let test_render_rt_tag_node test_ctxt =
    let reftree = load_reftree test_ctxt in
    let path = ["system"; "login"; "user"; "full-name"] in
    let node = CT.make "root" in
    let node = CT.set node path (Some "name here") CT.AddValue in
    let rendered_curly_config = CT.render ~reftree node in
    let desired_rendered_form =
"root {
    system {
        login {
            user {
                user full-name \"name here\";
            }
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
    let rendered_curly_config = CT.render ~reftree node in
    let desired_rendered_form =
"root {
    system {
        login {
            user {
                unspecified_node \"name here\";
            }
        }
    }
}"
    in
    assert_equal rendered_curly_config desired_rendered_form

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
        "test_valueless_node_inactive_ephemeral" >:: test_valueless_node_inactive_ephemeral;
        "test_set_inactive" >:: test_set_inactive;
        "test_set_ephemeral" >:: test_set_ephemeral;
        "test_render_nested_empty_with_comment" >:: test_render_nested_empty_with_comment;
        "test_render_ephemeral_hidden " >:: test_render_ephemeral_hidden;
        "test_render_ephemeral_shown"  >:: test_render_ephemeral_shown;
        "test_render_rt_tag_node" >:: test_render_rt_tag_node;
        "test_render_rt_unspecified_node" >:: test_render_rt_unspecified_node
    ]

let () =
  run_test_tt_main suite
