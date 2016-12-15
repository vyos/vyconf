open OUnit2
open Reference_tree

let get_dir test_ctxt = in_testdata_dir test_ctxt ["validators"]

let raises_validation_error f =
    try ignore @@ f (); false
    with Validation_error _ -> true

let test_load_valid_definition test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (Vytree.list_children r) ["system"]

(* Path validation tests *)
let test_validate_path_leaf_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (validate_path (get_dir test_ctxt) r ["system"; "host-name"; "test"]) (["system"; "host-name"], Some "test")

let test_validate_path_leaf_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ validate_path (get_dir test_ctxt) r ["system"; "host-name"; "1234"])) true

let test_validate_path_leaf_incomplete test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ validate_path (get_dir test_ctxt) r ["system"; "host-name"])) true

let test_validate_path_tag_node_complete_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (validate_path (get_dir test_ctxt) r ["system"; "login"; "user"; "test"; "full-name"; "test user"])
                 (["system"; "login"; "user"; "test"; "full-name";], Some "test user")

let test_validate_path_tag_node_invalid_name test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ validate_path (get_dir test_ctxt) r ["system"; "login"; "user"; "999"; "full-name"; "test user"]))
                 true

let test_validate_path_tag_node_incomplete test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ validate_path (get_dir test_ctxt) r ["system"; "login"; "user"])) true


let suite =
    "Util tests" >::: [
        "test_load_valid_definition" >:: test_load_valid_definition;
        "test_validate_path_leaf_valid" >:: test_validate_path_leaf_valid;
        "test_validate_path_leaf_invalid" >:: test_validate_path_leaf_invalid;
        "test_validate_path_leaf_incomplete" >:: test_validate_path_leaf_incomplete;
        "test_validate_path_tag_node_complete_valid" >:: test_validate_path_tag_node_complete_valid;
        "test_validate_path_tag_node_invalid_name" >:: test_validate_path_tag_node_invalid_name;
        "test_validate_path_tag_node_incomplete" >:: test_validate_path_tag_node_incomplete;
    ]

let () =
  run_test_tt_main suite

