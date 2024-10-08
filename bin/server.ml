let cache_middleware ~dev next_handler request =
  let open Lwt.Syntax in
  if (not dev) && Dream.target request |> String.starts_with ~prefix:"/static"
  then (
    let+ response = next_handler request in
    Dream.add_header response "Cache-Control" "max-age=86400";
    response)
  else next_handler request
;;

let livereload ~dev inner_handler request =
  if dev then Dream.livereload inner_handler request else inner_handler request
;;

let serve ?(dev = false) site port =
  Dream.log
    "Server is up and running with mode %s and with css %s"
    (if dev then "dev" else "production")
    Css.hash;
  Dream.run ~port
  @@ Dream.logger
  @@ Dream_encoding.compress
  @@ livereload ~dev
  @@ cache_middleware ~dev
  @@ Dream.router
       [ Dream.get "/health" (fun _ -> Dream.html "OK")
       ; Dream.get "/" (fun _ -> Dream.html site)
       ; Dream.get "/index.html" (fun _ -> Dream.html site)
       ; Dream.get "/install" (fun request -> Dream.redirect request "/static/install")
       ; Dream.get "/static/**" @@ Dream.static "static"
       ]
;;
