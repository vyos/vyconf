open OUnit2
open Vytree

(* Destructuting a freshly made node gives us what
   we made it from *)
let test_make_node test_ctxt =
    let node = make () "root" in
    assert_equal (name_of_node node) "root";
    assert_equal (data_of_node node) ();
    assert_equal (children_of_node node) []

(* XXX: these comparisons are awkward, but this is
        probably the only way to track the problem
        down to insert if insert breaks *)

(* Inserting at single-item path adds a child to
   children list *)
let test_insert_immediate_child test_ctxt =
    let node = make () "root" in
    let node' = insert node ["foo"] () in
    assert_equal (children_of_node node')
                 [make () "foo"]

(* Inserting one child after another adds it to the
   end of the children list *)
let test_insert_multiple_children test_ctxt =
    let node = make () "root" in
    let node' = insert node ["foo"] () in
    let node'' = insert node' ["bar"] () in
    assert_equal (children_of_node node'')
                 [make () "bar"; make () "foo"]

(* Inserting a child at a two-item path creates a tree
   two levels deep *)
let test_insert_multi_level test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    let node = insert node ["foo"; "bar"] () in
    let bar = make () "bar" in
    let foo = make_full () "foo" [bar] in
    let root = make_full () "root" [foo] in
    assert_equal root node

(* Inserting duplicate child fails *)
let test_insert_duplicate_child test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    assert_raises Duplicate_child (fun () -> insert node ["foo"] ())

(* list_children correctly returns a list of children names *)
let test_list_children test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    let node = insert node ["bar"] () in
    assert_equal (list_children node) ["bar"; "foo"]

(* Deleting a child, well, deletes it *)
let test_delete_immediate_child test_ctxt =
    let node = make () "root" in
    let node' = insert node ["foo"] () in
    let node' = delete node' ["foo"] in
    assert_equal node node'

(* Deleting a child at multi-level path works *)
let test_delete_multi_level test_ctxt =
    let node = make () "root" in
    let node' = insert node ["foo"] () in
    let node' = insert node' ["foo"; "bar"] () in
    let foo_node = insert node ["foo"] () in
    let node' = delete node' ["foo"; "bar"] in
    assert_equal node' foo_node

(* Attempt to delete a node at non-existent path raises an exception *)
let test_delete_nonexistent test_ctxt =
    let node = make () "root" in
    assert_raises Nonexistent_path (fun () -> delete node ["foo"; "bar"])

(* get_child works with immediate children *)
let test_get_immediate_child test_ctxt =
    let node = make () "root" in
    let node' = insert node ["foo"] () in
    assert_equal (name_of_node (get node' ["foo"])) "foo"

(* get_child works with multi-level paths *)
let test_get_child_multilevel test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    let node = insert node ["foo"; "bar"] () in
    assert_equal (name_of_node (get node ["foo"; "bar"])) "bar"

(* get_child raises Nonexistent_path for non-existent paths *)
let test_get_child_nonexistent test_ctxt =
    let node = make () "root" in
    assert_raises Nonexistent_path (fun () -> get node ["foo"; "bar"])

(* update works *)
let test_update test_ctxt =
    let node = make 0 "root" in
    let node = insert node ["foo"] 1 in
    assert_equal (data_of_node (get (update node ["foo"] 9) ["foo"])) 9

(* get_existent_path works *)
let test_get_existent_path test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    let node = insert node ["foo"; "bar"] () in
    assert_equal (get_existent_path node ["foo"; "bar"; "baz"]) ["foo"; "bar"]

let test_exists_existent test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    let node = insert node ["foo"; "bar"] () in
    assert_equal (exists node ["foo"; "bar"]) true

let test_exists_nonexistent test_ctxt =
    let node = make () "root" in
    let node = insert node ["foo"] () in
    let node = insert node ["foo"; "bar"] () in
    assert_equal (exists node ["foo"; "bar"; "baz"]) false


let suite =
    "VyConf tree tests" >::: [
        "test_make_node" >:: test_make_node;
        "test_insert_immediate_child" >:: test_insert_immediate_child;
        "test_insert_multiple_children" >:: test_insert_multiple_children;
        "test_insert_multi_level" >:: test_insert_multi_level;
        "test_insert_duplicate_child" >:: test_insert_duplicate_child;
        "test_list_children" >:: test_list_children;
        "test_delete_immediate_child" >:: test_delete_immediate_child;
        "test_delete_multi_level" >:: test_delete_multi_level;
        "test_delete_nonexistent" >:: test_delete_nonexistent;
        "test_get_immediate_child" >:: test_get_immediate_child;
        "test_get_child_multilevel" >:: test_get_child_multilevel;
        "test_get_child_nonexistent" >:: test_get_child_nonexistent;
        "test_update" >:: test_update;
        "test_get_existent_path" >:: test_get_existent_path;
        "test_exists_existent" >:: test_exists_existent;
        "test_exists_nonexistent" >:: test_exists_nonexistent;
    ]

let () =
  run_test_tt_main suite

