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

let test_validate_path_garbage_after_value test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ validate_path (get_dir test_ctxt) r ["system"; "host-name"; "foo"; "bar"])) true

let test_validate_path_valueless_node_with_value test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ validate_path (get_dir test_ctxt) r ["system"; "options"; "reboot-on-panic"; "fgsfds"])) true

let test_validate_path_valueless_node_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (validate_path (get_dir test_ctxt) r ["system"; "options"; "reboot-on-panic"])
                 (["system"; "options"; "reboot-on-panic"], None)

let test_is_multi_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_multi r ["system"; "ntp-server"]) true

let test_is_multi_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_multi r ["system"; "host-name"]) false

let test_is_secret_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_secret r ["system"; "login"; "password"]) true

let test_is_secret_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_secret r ["system"; "login"; "user"; "full-name"]) false

let test_is_hidden_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_hidden r ["system"; "options"; "enable-dangerous-features"]) true

let test_is_hidden_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_hidden r ["system"; "login"; "user"; "full-name"]) false

let test_is_tag_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_tag r ["system"; "login"; "user"]) true

let test_is_tag_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_tag r ["system"; "login"]) false

let test_is_leaf_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_leaf r ["system"; "login"; "user"; "full-name"]) true

let test_is_leaf_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_leaf r ["system"; "login"; "user"]) false

let test_is_valueless_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_valueless r ["system"; "options"; "reboot-on-panic"]) true

let test_is_valueless_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (is_valueless r ["system"; "login"; "user"; "full-name"]) false

let test_get_keep_order_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_keep_order r ["system"; "login"; "user"]) true

let test_get_keep_order_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_keep_order r ["system"; "login"; "user"; "full-name"]) false

let test_get_owner_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_owner r ["system"; "login"]) (Some "login")

let test_get_owner_invalid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_owner r ["system"; "login"; "user"]) None

let test_get_help_string_valid test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_help_string r ["system"; "login"; "user"; "full-name"]) ("User full name")

let test_get_help_string_default test_ctxt =
    let r = Vytree.make default_data "root" in
    let r = load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_help_string r ["system"; "host-name"]) ("No help available")

let suite =
    "Util tests" >::: [
        "test_load_valid_definition" >:: test_load_valid_definition;
        "test_validate_path_leaf_valid" >:: test_validate_path_leaf_valid;
        "test_validate_path_leaf_invalid" >:: test_validate_path_leaf_invalid;
        "test_validate_path_leaf_incomplete" >:: test_validate_path_leaf_incomplete;
        "test_validate_path_tag_node_complete_valid" >:: test_validate_path_tag_node_complete_valid;
        "test_validate_path_tag_node_invalid_name" >:: test_validate_path_tag_node_invalid_name;
        "test_validate_path_tag_node_incomplete" >:: test_validate_path_tag_node_incomplete;
        "test_validate_path_garbage_after_value" >:: test_validate_path_garbage_after_value;
        "test_validate_path_valueless_node_with_value" >:: test_validate_path_valueless_node_with_value;
        "test_validate_path_valueless_node_valid" >:: test_validate_path_valueless_node_valid;
        "test_is_multi_valid" >:: test_is_multi_valid;
        "test_is_multi_invalid" >:: test_is_multi_invalid;
        "test_is_secret_valid" >:: test_is_secret_valid; 
        "test_is_secret_invalid" >:: test_is_secret_invalid;
        "test_is_hidden_valid" >:: test_is_hidden_valid; 
        "test_is_hidden_invalid" >:: test_is_hidden_invalid;
        "test_is_tag_valid" >:: test_is_tag_valid;
        "test_is_tag_invalid" >:: test_is_tag_invalid;
        "test_is_leaf_valid" >:: test_is_leaf_valid;
        "test_is_leaf_invalid" >:: test_is_leaf_invalid;
        "test_is_valueless_valid" >:: test_is_valueless_valid;
        "test_is_valueless_invalid" >:: test_is_valueless_invalid;
        "test_get_keep_order_valid" >:: test_get_keep_order_valid; 
        "test_get_keep_order_invalid" >:: test_get_keep_order_invalid;
        "test_get_owner_valid" >:: test_get_owner_valid;
        "test_get_owner_invalid" >:: test_get_owner_invalid;
        "test_get_help_string_valid" >:: test_get_help_string_valid;
        "test_get_help_string_default" >:: test_get_help_string_default;
    ]

let () =
  run_test_tt_main suite

