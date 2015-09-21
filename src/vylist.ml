let rec find p xs =
    match xs with
    | [] -> None
    | y :: ys -> if (p y) then (Some y)
                  else find p ys

let rec remove p xs =
    match xs with
    | [] -> []
    | y :: ys -> if (p y) then ys
                  else y :: (remove p ys)

let rec replace p x xs =
    match xs with
    | [] -> raise Not_found
    | y :: ys -> if (p y) then x :: ys
                   else y :: (replace p x ys)

let rec insert_before p x xs =
    match xs with
    | [] -> raise Not_found
    | y :: ys -> if (p y) then x :: y :: ys
                 else y :: (insert_before p x ys)

let rec insert_after p x xs =
    match xs with
    | [] -> raise Not_found
    | y :: ys -> if (p y) then y :: x :: ys
                 else y :: (insert_after p x ys)

let complement xs ys =
    let rec aux xs ys =
        match xs, ys with
        | [], _ -> ys
        | _, [] -> assert false (* Can't happen *)
        | p :: ps, q :: qs -> if p = q then aux ps qs
                              else []
    in
    if List.length xs < List.length ys then aux xs ys
    else aux ys xs

let in_list xs x =
    let x' = find ((=) x) xs in
    match x' with
    | None -> false
    | Some _ -> true
