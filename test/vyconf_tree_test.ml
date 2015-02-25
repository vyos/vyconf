open OUnit2
open Vytree

(* Destructuting a freshly made node gives us what
   we made it from *)
let test_make_node test_ctxt =
    let node = make "root" () in
    assert_equal (name_of_node node) "root";
    assert_equal (data_of_node node) ();
    assert_equal (children_of_node node) []

(* XXX: these comparisons are awkward, but this is
        probably the only way to track the problem
        down to insert if insert breaks *)

(* Inserting at single-item path adds a child to
   children list *)
let test_insert_immediate_child test_ctxt =
    let node = make "root" () in
    let node' = insert_child () node ["foo"] () in
    assert_equal (children_of_node node')
                 [make "foo" ()]

(* Inserting one child after another adds it to the
   end of the children list *)
let test_insert_multiple_children test_ctxt =
    let node = make "root" () in
    let node' = insert_child () node ["foo"] () in
    let node'' = insert_child () node' ["bar"] () in
    assert_equal (children_of_node node'')
                 [make "foo" (); make "bar" ()]

(* Inserting a child at a two-item path creates a tree
   two levels deep *)
let test_insert_multi_level test_ctxt =
    let node = make "root" () in
    let node' = insert_child () node ["foo"; "bar"] () in
    let bar = make "bar" () in
    let foo = make_full "foo" () [bar] in
    let root = make_full "root" () [foo] in
    assert_equal root node'

(* list_children correctly returns a list of children names *)
let test_list_children test_ctxt =
    let node = make "root" () in
    let node' = insert_child () node ["foo"] () in
    let node'' = insert_child () node' ["bar"] () in
    assert_equal (list_children node'') ["foo"; "bar"]

let suite =
    "VyConf tree tests" >::: [
        "test_make_node" >:: test_make_node;
        "test_insert_immediate_child" >:: test_insert_immediate_child;
        "test_insert_multiple_children" >:: test_insert_multiple_children;
        "test_insert_multi_level" >:: test_insert_multi_level;
        "test_list_children" >:: test_list_children;
    ]

let () =
  run_test_tt_main suite

