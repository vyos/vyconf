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
        | [], _ -> Some ys
        | _, [] -> assert false (* Can't happen *)
        | p :: ps, q :: qs -> if p = q then aux ps qs
                              else None
    in
    if List.length xs < List.length ys then aux xs ys
    else aux ys xs
