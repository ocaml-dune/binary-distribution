module List = struct
  let take n xs =
    let rec aux k acc = function
      | [] -> acc
      | x :: xs -> if k < n then aux (k + 1) (x :: acc) xs else acc
    in
    aux 0 [] xs |> List.rev
  ;;
end
