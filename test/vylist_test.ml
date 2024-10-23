[@@@ocaml.warning "-27"]

open OUnit2
open Vyos1x.Vylist

(* Searching for an element that is in the list gives Some that_element *)
let test_find_existent test_ctxt =
    let xs = [1; 2; 3; 4] in
    assert_equal (find (fun x -> x = 3) xs) (Some 3)

(* Searching for an element that is not in the list gives None *)
let test_find_nonexistent test_ctxt =
    let xs = [1; 2; 4] in
    assert_equal (find (fun x -> x = 3) xs) None

(* Removing an element that exists in the list makes a list without that element *)
let test_remove_existent test_ctct =
    let xs = [1; 2; 3; 4] in
    assert_equal (remove (fun x -> x = 3) xs) [1; 2; 4]

(* Trying to remove an element that is not in the list doesn't change the list *)
let test_remove_nonexistent test_ctct =
    let xs = [1; 2; 4] in
    assert_equal (remove (fun x -> x = 3) xs) [1; 2; 4]

(* Replacing an element works *)
let test_replace_element_existent test_ctxt =
    let xs = [1; 2; 3; 4] in
    assert_equal (replace ((=) 3) 7 xs) [1; 2; 7; 4]

(* Attempt to replace a nonexistent element causes an exception *)
let test_replace_element_nonexistent test_ctxt =
    let xs = [1; 2; 3] in
    assert_raises Not_found (fun () -> replace ((=) 4) 7 xs)

(* insert_before works if the element is there *)
let test_insert_before_existent test_ctxt =
    let xs = [1; 2; 3] in
    assert_equal (insert_before ((=) 2) 7 xs) [1; 7; 2; 3]

(* insert_before raises Not_found if there's not such element *)
let test_insert_before_nonexistent test_ctxt =
    let xs = [1; 2; 3] in
     assert_raises Not_found (fun () -> insert_before ((=) 9) 7 xs)

(* complement returns correct result when one list contains another, in any order *)
let test_complement_first_is_longer test_ctxt =
    let xs = [1; 2; 3; 4; 5] and ys = [1; 2; 3] in
    assert_equal (complement xs ys) [4; 5]

let test_complement_second_is_longer test_ctxt =
    let	xs = [1; 2] and ys = [1; 2; 3; 4; 5] in
    assert_equal (complement xs	ys) [3; 4; 5]

(* complement returns an empty list if one list doesn't contain another *)
let test_complement_doesnt_contain test_ctxt =
    let xs = [1; 2; 3] and ys = [1; 4; 5; 6] in
    assert_equal (complement xs ys) []

(* in_list works *)
let test_in_list test_ctxt =
    let xs = [1; 2; 3; 4] in
    assert_equal (in_list xs 3) true;
    assert_equal (in_list xs 9) false

let suite =
    "VyConf list tests" >::: [
        "test_find_existent" >:: test_find_existent;
        "test_find_nonexistent" >:: test_find_nonexistent;
        "test_remove_existent" >:: test_remove_existent;
        "test_remove_nonexistent" >:: test_remove_nonexistent;
        "test_replace_element_existent" >:: test_replace_element_existent;
        "test_replace_element_nonexistent" >:: test_replace_element_nonexistent;
        "test_insert_before_existent" >:: test_insert_before_existent;
        "test_insert_before_nonexistent" >:: test_insert_before_nonexistent;
        "test_complement_first_is_longer" >:: test_complement_first_is_longer;
        "test_complement_second_is_longer" >:: test_complement_second_is_longer;
        "test_complement_doesnt_contain" >:: test_complement_doesnt_contain;
        "test_in_list" >:: test_in_list;
    ]

let () =
  run_test_tt_main suite

