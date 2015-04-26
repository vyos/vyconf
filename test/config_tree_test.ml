open OUnit2

module VT = Vytree
open Config_tree

let test_set_value test_ctxt =
    let node = make "root" in
    let node = VT.insert node ["foo"] default_data in
    let node = set_value node ["foo"] "bar" in
    let data = VT.data_of_node (VT.get node ["foo"]) in
    assert_equal data.values ["bar"]

let test_get_values test_ctxt =
    let node = make "root" in
    let node = VT.insert node ["foo"] default_data in
    let node = set_value node ["foo"] "bar" in
    assert_equal (get_values node ["foo"]) ["bar"]

let test_add_value test_ctxt =
    let node = make "root" in
    let node = VT.insert node ["foo"] default_data in
    let node = add_value node ["foo"] "bar" in
    let node = add_value node ["foo"] "baz" in
    assert_equal (get_values node ["foo"]) ["bar"; "baz"]

let test_add_value_duplicate test_ctxt =
    let node = make "root" in
    let node = VT.insert node ["foo"] default_data in
    let node = set_value node ["foo"] "bar" in
    assert_raises Duplicate_value (fun () -> add_value node ["foo"] "bar")

let suite =
    "VyConf config tree tests" >::: [
        "test_set_value" >:: test_set_value;
        "test_get_values" >:: test_get_values;
        "test_add_value" >:: test_add_value;
        "test_add_value_duplicate" >:: test_add_value_duplicate;
    ]

let () =
  run_test_tt_main suite

