let export_website_to_string ~title content = Container.page ~title content |> JSX.render

let generate_main_page ~title ~base_url releases =
  Main.page ~base_url ~releases () |> export_website_to_string ~title
;;

let generate_error_page ~title ~code reason =
  Error.page ~code ~reason () |> export_website_to_string ~title
;;

module Route = struct
  let empty = []
  let add ~path page routes = (path, page) :: routes
end
