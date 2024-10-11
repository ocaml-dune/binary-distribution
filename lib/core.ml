module List = struct
  let take n xs =
    let rec aux acc = function
      | 0, _ | _, [] -> acc
      | k, x :: xs -> aux (x :: acc) (k - 1, xs)
    in
    aux [] (n, xs) |> List.rev
  ;;
end
