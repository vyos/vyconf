let rec find p xs =
    match xs with
    | [] -> None
    | x :: xs' -> if (p x) then (Some x)
                  else find p xs'

let rec remove p xs =
    match xs with
    | [] -> []
    | x :: xs' -> if (p x) then xs'
                  else x :: (remove p xs)

let rec replace p x xs=
    match xs with
    | [] -> []
    | x' :: xs' -> if (p x') then x :: xs'
                   else x' :: (replace p x xs')
