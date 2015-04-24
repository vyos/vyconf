open OUnit2
open Reference_tree

let test_load_valid_definition test_ctxt =
    assert_equal 0 0

let suite =
    "Util tests" >::: [
        "test_load_valid_definition" >:: test_load_valid_definition;
    ]

let () =
  run_test_tt_main suite

