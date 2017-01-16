open OUnit2
open Value_checker

let get_dir test_ctxt = in_testdata_dir test_ctxt ["validators"]

let raises_bad_validator f =
    try ignore @@ f (); false
    with Bad_validator _ -> true

let test_check_regex_valid test_ctxt =
    let c = Regex "[a-z]+" in
    let v = "fgsfds" in
    assert_equal (validate_value (get_dir test_ctxt) c v) true

let test_check_regex_invalid test_ctxt =
    let c = Regex "[a-z]+" in
    let v = "FGSFDS" in
    assert_equal (validate_value (get_dir test_ctxt) c v) false

let test_check_external_valid test_ctxt =
    let c = External ("anything", None) in
    let v = "fgsfds" in
    assert_equal (validate_value (get_dir test_ctxt) c v) true

let test_check_external_invalid test_ctxt =
    let	c = External ("nothing", None) in
    let	v = "fgsfds" in
    assert_equal (validate_value (get_dir test_ctxt) c v) false

let test_check_external_bad_validator test_ctxt =
    let c = External ("invalid", None) in
    let v = "fgsfds" in
    assert_bool "Invalid validator was executed successfully"
      (raises_bad_validator (fun () -> validate_value (get_dir test_ctxt) c v))

let test_validate_any_valid test_ctxt =
    let cs = [Regex "\\d+"; Regex "[a-z]+"; External ("anything", None)] in
    assert_equal (validate_any (get_dir test_ctxt) cs "AAAA") true

let test_validate_any_invalid test_ctxt =
    let cs = [Regex "\\d+"; Regex "[a-z]+"] in
    assert_equal (validate_any (get_dir test_ctxt) cs "AAAA") false

let test_validate_any_no_constraints test_ctxt =
    let cs = [] in
    assert_equal (validate_any (get_dir test_ctxt) cs "foo") true

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

