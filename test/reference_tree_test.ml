open OUnit2

module RT = Vyos1x.Reference_tree
module VT = Vyos1x.Vytree
module VL = Vyos1x.Vylist

let get_dir test_ctxt = in_testdata_dir test_ctxt ["validators"]

let ok_or_failure result = match result with
    | Ok value  -> value
    | Error msg -> assert_failure msg

let raises_validation_error f =
    try ignore @@ f (); false
    with RT.Validation_error _ -> true

let test_load_valid_definition test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (VL.in_list (VT.list_children r) "system") true;
    assert_equal (VL.in_list (VT.list_children r) "interfaces") true

(* Path validation tests *)
let test_validate_path_leaf_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    let test p =
        let _ = RT.validate_path (get_dir test_ctxt) r p in
        RT.split_path r p
    in
    assert_equal (test ["system"; "host-name"; "test"]) (["system"; "host-name"], Some "test")

let test_validate_path_leaf_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["system"; "host-name"; "1234"])) true

let test_validate_path_leaf_incomplete test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["system"; "host-name"])) true

let test_validate_path_tag_node_complete_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    let test p =
        let _ = RT.validate_path (get_dir test_ctxt) r p in
        RT.split_path r p
    in
    assert_equal (test ["system"; "login"; "user"; "test"; "full-name"; "test user"])
                 (["system"; "login"; "user"; "test"; "full-name";], Some "test user")

let test_validate_path_tag_node_illegal_characters test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    (* the space in "eth 0" is on purpose *)
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["interfaces"; "ethernet"; "eth 0"; "disable"])) true

let test_validate_path_tag_node_invalid_name test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["system"; "login"; "user"; "999"; "full-name"; "test user"]))
                 true

let test_validate_path_tag_node_incomplete test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["system"; "login"; "user"])) true

let test_validate_path_garbage_after_value test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["system"; "host-name"; "foo"; "bar"])) true

let test_validate_path_valueless_node_with_value test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (raises_validation_error (fun () -> ignore @@ RT.validate_path (get_dir test_ctxt) r ["system"; "options"; "reboot-on-panic"; "fgsfds"])) true

let test_validate_path_valueless_node_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    let test p =
        let _ = RT.validate_path (get_dir test_ctxt) r p in
        RT.split_path r p
    in
    assert_equal (test ["system"; "options"; "reboot-on-panic"])
                 (["system"; "options"; "reboot-on-panic"], None)

let test_is_multi_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_multi r ["system"; "ntp-server"]) true

let test_is_multi_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_multi r ["system"; "host-name"]) false

let test_is_secret_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_secret r ["system"; "login"; "password"]) true

let test_is_secret_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_secret r ["system"; "login"; "user"; "full-name"]) false

let test_is_hidden_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_hidden r ["system"; "options"; "enable-dangerous-features"]) true

let test_is_hidden_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_hidden r ["system"; "login"; "user"; "full-name"]) false

let test_is_tag_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_tag r ["system"; "login"; "user"]) true

let test_is_tag_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_tag r ["system"; "login"]) false

let test_is_leaf_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_leaf r ["system"; "login"; "user"; "full-name"]) true

let test_is_leaf_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_leaf r ["system"; "login"; "user"]) false

let test_is_valueless_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_valueless r ["system"; "options"; "reboot-on-panic"]) true

let test_is_valueless_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.is_valueless r ["system"; "login"; "user"; "full-name"]) false

(* keep_order not yet implemented *)
(*
let test_get_keep_order_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_keep_order r ["system"; "login"; "user"]) true

let test_get_keep_order_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (get_keep_order r ["system"; "login"; "user"; "full-name"]) false
*)
let test_get_owner_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.get_owner r ["system"; "login"]) (Some "login")

let test_get_owner_invalid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.get_owner r ["system"; "login"; "user"]) None

let test_get_help_string_valid test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.get_help_string r ["system"; "login"; "user"; "full-name"]) ("User full name")

let test_get_help_string_default test_ctxt =
    let r = VT.make RT.default_data "root" in
    let r = RT.load_from_xml r (in_testdata_dir test_ctxt ["interface_definition_sample.xml"]) in
    assert_equal (RT.get_help_string r ["system"; "host-name"]) ("No help available")


let suite =
    "Vyconf reference tree tests" >::: [
        "test_load_valid_definition" >:: test_load_valid_definition;
        "test_validate_path_leaf_valid" >:: test_validate_path_leaf_valid;
        "test_validate_path_leaf_invalid" >:: test_validate_path_leaf_invalid;
        "test_validate_path_leaf_incomplete" >:: test_validate_path_leaf_incomplete;
        "test_validate_path_tag_node_illegal_characters" >:: test_validate_path_tag_node_illegal_characters;
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
        "test_get_owner_valid" >:: test_get_owner_valid;
        "test_get_owner_invalid" >:: test_get_owner_invalid;
        "test_get_help_string_valid" >:: test_get_help_string_valid;
        "test_get_help_string_default" >:: test_get_help_string_default
    ]

let () =
  run_test_tt_main suite

