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
    ]

let () =
  run_test_tt_main suite 
