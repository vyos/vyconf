open OUnit2
open Reference_tree

let test_load_valid_definition test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (Vytree.list_children r) ["login"]

let suite =
    "Util tests" >::: [
        "test_load_valid_definition" >:: test_load_valid_definition;
    ]

let () =
  run_test_tt_main suite

