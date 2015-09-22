open OUnit2

module VT = Vytree
module CT = Config_tree
 
let test_set_create_node test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path "baz" CT.ReplaceValue in
    let values = CT.get_values node path in
    assert_equal values ["baz"]

(* Deleting just one of many values should keep all other values intact *)
let test_delete_just_value test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path "baz" CT.AddValue in
    let node = CT.set node path "quux" CT.AddValue in
    let node = CT.delete node path (Some "quux") in
    assert_equal (CT.get_values node path) ["baz"]

(* Deleting the last value should delete the whole leaf *)
let test_delete_last_value test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path "baz" CT.AddValue in
    let node = CT.delete node path (Some "baz") in
    assert_equal ((not (VT.exists node path)) && (VT.exists node ["foo"])) true

(* Deleting a non-leaf node should delete the whole subtree *)
let test_delete_subtree test_ctxt =
    let path = ["foo"; "bar"] in
    let node = CT.make "root" in
    let node = CT.set node path "baz" CT.AddValue in
    let node = CT.delete node path None in
    assert_equal (VT.list_children node) []


let suite =
    "VyConf config tree tests" >::: [
        "test_set_create_node" >:: test_set_create_node;
        "test_delete_just_value" >:: test_delete_just_value;
        "test_delete_last_value" >:: test_delete_last_value;
    ]

let () =
  run_test_tt_main suite 
