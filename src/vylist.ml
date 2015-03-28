let rec find p xs =
    match xs with
    | [] -> None
    | x :: xs' -> if (p x) then (Some x)
                  else find p xs'

let rec remove p xs =
    match xs with
    | [] -> []
    | x :: xs' -> if (p x) then xs'
                  else x :: (remove p xs')

let rec replace p x xs =
    match xs with
    | [] -> raise Not_found
    | x' :: xs' -> if (p x') then x :: xs'
                   else x' :: (replace p x xs')

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
