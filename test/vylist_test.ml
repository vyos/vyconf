open OUnit2
open Vylist

(* Searching for an element that is there gives Some that_element *)
let test_find_existent test_ctxt =
    let xs = [1; 2; 3; 4] in
    assert_equal (find (fun x -> x = 3) xs) (Some 3)

(* Searching for an element that is not there gives None *)
let test_find_nonexistent test_ctxt =
    let xs = [1; 2; 4] in
    assert_equal (find (fun x -> x = 3) xs) None

(* Removing a list that is there makes a list without that element *)
let test_remove_existent test_ctct =
    let xs = [1; 2; 3; 4] in
    assert_equal (remove (fun x -> x = 3) xs) [1; 2; 4]

(* Removing an element that is already not there returns the same list *)
let test_remove_nonexistent test_ctct =
    let xs = [1; 2; 4] in
    assert_equal (remove (fun x -> x = 3) xs) [1; 2; 4]

(* Replacing an element works *)
let test_replace_element_existent test_ctxt =
    let xs = [1; 2; 3; 4] in
    assert_equal (replace ((=) 3) 7 xs) [1; 2; 7; 4]

(* Attempt to replace a nonexisten child rauses an exception *)
let test_replace_element_nonexistent test_ctxt =
    let xs = [1; 2; 3] in
    assert_raises Not_found (fun () -> replace ((=) 4) 7 xs)

let suite =
    "VyConf list tests" >::: [
        "test_find_existent" >:: test_find_existent;
        "test_find_nonexistent" >:: test_find_nonexistent;
        "test_remove_existent" >:: test_remove_existent;
        "test_remove_nonexistent" >:: test_remove_nonexistent;
        "test_replace_element_existent" >:: test_replace_element_existent;
        "test_replace_element_nonexistent" >:: test_replace_element_nonexistent;
    ]

let () =
  run_test_tt_main suite

