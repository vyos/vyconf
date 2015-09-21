open OUnit2

module VT = Vytree
open Config_tree
 
let test_set_create_node test_ctxt =
    let node = make "root" in
    let node = set node ["foo"; "bar"] "baz" ReplaceValue in
    let data = VT.get_data node ["foo"; "bar"] in
    assert_equal data.values ["baz"]


let suite =
    "VyConf config tree tests" >::: [
        "test_set_create_node" >:: test_set_create_node;
    ]

let () =
  run_test_tt_main suite 
