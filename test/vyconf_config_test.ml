open OUnit2
open Vyconfd_config.Vyconf_config

let try_load file =
    let conf = load file in
    match conf with
    | Ok _ -> ()
    | Error msg -> assert_failure msg

let try_load_fail file err =
    let conf = load file in
    match conf with
    | Ok _ -> assert_failure err
    | Error _ -> ()

let test_load_nonexistent_file test_ctxt =
    (* Please don't create this file there! *)
    let file = in_testdata_dir test_ctxt ["vyconfd_config"; "vyconfd.conf.nonexistent"] in
    try_load_fail file (Printf.sprintf "Nonexistent file %s was successfully loaded" file)

let test_load_malformed_file test_ctxt =
    let file = in_testdata_dir test_ctxt ["vyconfd_config"; "vyconfd.conf.malformed"] in
    try_load_fail file (Printf.sprintf "Malformed file %s was successfully loaded" file)

let test_load_incomplete_file test_ctxt =
    let file = in_testdata_dir test_ctxt ["vyconfd_config"; "vyconfd.conf.incomplete"] in
    try_load_fail file (Printf.sprintf "File %s was successfully loaded despite missing fields" file)

let test_load_mandatory_only test_ctxt =
    let file = in_testdata_dir test_ctxt ["vyconfd_config"; "vyconfd.conf.mandatoryonly"] in
    try_load file

let test_load_all_fields test_ctxt =
    let file = in_testdata_dir test_ctxt ["vyconfd_config"; "vyconfd.conf.complete"] in
    try_load file

let suite =
    "VyConf daemon config loader tests" >::: [
        "test_load_nonexistent_file" >:: test_load_nonexistent_file;
        "test_load_malformed_file" >:: test_load_malformed_file;
        "test_load_incomplete_file" >:: test_load_incomplete_file;
        "test_load_mandatory_only" >:: test_load_mandatory_only;
        "test_load_all_fields" >:: test_load_all_fields;

    ]

let () =
  run_test_tt_main suite
