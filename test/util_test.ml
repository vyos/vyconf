open OUnit2
open Util

let test_find_xml_child_existent test_ctxt =
    let elem = Xml.Element ("foo", [],
                            [Xml.Element ("bar", [], []);
                             Xml.PCData "baz"])
    in
    match (find_xml_child "bar" elem) with
    | None -> assert_failure "find_xml_child returned None"
    | Some x -> assert_equal (Xml.tag x) "bar"

let test_find_xml_child_nonexistent test_ctxt =
    let elem = Xml.Element ("foo", [], [Xml.Element ("quux", [], [])]) in
    assert_equal (find_xml_child "bar" elem) None

let test_string_of_path test_ctxt =
    let path = ["foo"; "bar"; "baz"] in
    assert_equal (String.trim (string_of_path path)) "foo bar baz"

let suite =
    "Util tests" >::: [
        "test_find_xml_child_existent" >:: test_find_xml_child_existent;
        "test_find_xml_child_nonexistent" >:: test_find_xml_child_nonexistent;
        "test_string_of_path" >:: test_string_of_path;
    ]

let () =
  run_test_tt_main suite

