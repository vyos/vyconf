open OUnit2
open Value_checker

let validators = Hashtbl.create 256
let () = Hashtbl.add validators "anything" "true";
         Hashtbl.add validators "nothing" "false"

let test_check_regex_valid test_ctxt =
    let c = Regex "[a-z]+" in
    let v = "fgsfds" in
    assert_equal (validate_value validators c v) true

let test_check_regex_invalid test_ctxt =
    let c = Regex "[a-z]+" in
    let v = "FGSFDS" in
    assert_equal (validate_value validators c v) false

let test_check_external_valid test_ctxt =
    let c = External ("anything", "") in
    let v = "fgsfds" in
    assert_equal (validate_value validators c v) true

let test_check_external_invalid test_ctxt =
    let	c = External ("nothing", "") in
    let	v = "fgsfds" in
    assert_equal (validate_value validators c v) false

let test_check_external_bad_validator test_ctxt =
    let c = External ("invalid", "") in
    let v = "fgsfds" in
    assert_raises (Bad_validator "invalid") (fun () -> validate_value validators c v)


let suite =
    "VyConf value checker tests" >::: [
        "test_check_regex_valid" >:: test_check_regex_valid;
        "test_check_regex_invalid" >:: test_check_regex_invalid;
        "test_check_external_valid" >:: test_check_external_valid;
        "test_check_external_invalid" >:: test_check_external_invalid;
        "test_check_external_bad_validator" >:: test_check_external_bad_validator;
    ]

let () =
  run_test_tt_main suite

