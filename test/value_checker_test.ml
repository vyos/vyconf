open OUnit2

module VC = Vyos1x.Value_checker

let get_dir test_ctxt = in_testdata_dir test_ctxt ["validators"]

let buf = Buffer.create 4096

let raises_bad_validator f =
    try ignore @@ f (); false
    with VC.Bad_validator _ -> true

let test_check_regex_valid test_ctxt =
    let c = VC.Regex "[a-z]+" in
    let v = "fgsfds" in
    assert_equal (VC.validate_value (get_dir test_ctxt) buf c v) true

let test_check_regex_invalid test_ctxt =
    let c = VC.Regex "[a-z]+" in
    let v = "FGSFDS" in
    assert_equal (VC.validate_value (get_dir test_ctxt) buf c v) false

let test_check_external_valid test_ctxt =
    let c = VC.External ("anything", None) in
    let v = "fgsfds" in
    assert_equal (VC.validate_value (get_dir test_ctxt) buf c v) true

let test_check_external_invalid test_ctxt =
    let	c = VC.External ("nothing", None) in
    let	v = "fgsfds" in
    assert_equal (VC.validate_value (get_dir test_ctxt) buf c v) false

let test_check_external_bad_validator test_ctxt =
    let c = VC.External ("invalid", None) in
    let v = "fgsfds" in
    assert_bool "Invalid validator was executed successfully"
      (raises_bad_validator (fun () -> VC.validate_value (get_dir test_ctxt) buf c v))

let test_validate_any_valid test_ctxt =
    let cs = [VC.Regex "\\d+"; VC.Regex "[a-z]+"; VC.External ("anything", None)] in
    assert_equal (VC.validate_any (get_dir test_ctxt) cs "AAAA") None

let test_validate_any_invalid test_ctxt =
    let cs = [VC.Regex "\\d+"; VC.Regex "[a-z]+"] in
    assert_equal (VC.validate_any (get_dir test_ctxt) cs "AAAA") None

let test_validate_any_no_constraints test_ctxt =
    let cs = [] in
    assert_equal (VC.validate_any (get_dir test_ctxt) cs "foo") None

let suite =
    "VyConf value checker tests" >::: [
        "test_check_regex_valid" >:: test_check_regex_valid;
        "test_check_regex_invalid" >:: test_check_regex_invalid;
        "test_check_external_valid" >:: test_check_external_valid;
        "test_check_external_invalid" >:: test_check_external_invalid;
        "test_check_external_bad_validator" >:: test_check_external_bad_validator;
        "test_validate_any_valid" >:: test_validate_any_valid;
        "test_validate_any_invalid" >:: test_validate_any_invalid;
        "test_validate_any_no_constraints" >:: test_validate_any_no_constraints;
    ]

let () =
  run_test_tt_main suite

