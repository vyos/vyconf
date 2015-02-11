open OUnit2

let test1 test_ctxt = assert_equal 0 0

let suite =
    "VyConf tree tests" >::: [
        "test_dummy">:: test1;
    ]

let () =
  run_test_tt_main suite

