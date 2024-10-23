[@@@ocaml.warning "-27"]

open OUnit2
open Vyconfd_config.Session

module CT = Vyos1x.Config_tree
module RT = Vyos1x.Reference_tree


(* I'm not sure if we want to account for superfluous spaces inside the strings,
   but for now let's say we want strings "normalized"

   We also assume that quotes around the values are double quotes,
   even though the lexer will also accept single quotes.
 *)

let test_op_string_set test_ctxt =
    let op = CfgSet (["foo"; "bar"], Some "baz quux", CT.ReplaceValue) in
    let str = (String.trim @@ string_of_op op) in
    assert_equal str "set foo bar \"baz quux\""

let test_op_string_set_valueless test_ctxt =
    let op = CfgSet (["foo"; "bar"], None, CT.ReplaceValue) in
    let str = (String.trim @@ string_of_op op) in
    assert_equal str "set foo bar"

let test_op_string_delete test_ctxt =
    let op = CfgDelete (["foo"; "bar"], Some "baz quux") in
    let str = (String.trim @@ string_of_op op) in
    assert_equal str "delete foo bar \"baz quux\""


let suite =
    "VyConf session tests" >::: [
        "test_op_string_set" >:: test_op_string_set;
        "test_op_string_set_valueless" >:: test_op_string_set_valueless;
        "test_op_string_delete" >:: test_op_string_delete;
    ]

let () =
  run_test_tt_main suite

