open OUnit2
open Vytree

let test1 test_ctxt = assert_equal 0 0

let test_make_node test_ctxt =
    let node = make "root" () in
    assert_equal (name_of_node node) "root";
    assert_equal (data_of_node node) ();
    assert_equal (children_of_node node) []

let suite =
    "VyConf tree tests" >::: [
        "test_make_node" >:: test_make_node;
    ]

let () =
  run_test_tt_main suite

