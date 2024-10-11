let cache_middleware ~dev next_handler request =
  let open Lwt.Infix in
  if (not dev) && Dream.target request |> String.starts_with ~prefix:"/static"
  then (
    next_handler request
    >|= fun response ->
    Dream.add_header response "Cache-Control" "max-age=86400";
    response)
  else next_handler request
;;

let reload_script_middleware ~dev inner_handler request =
  if dev then Dream.livereload inner_handler request else inner_handler request
;;

let serve ~dev site port =
  let interface = if dev then "127.0.0.1" else "0.0.0.0" in
  Dream.log
    "Server is up and running with mode %s and with css %s"
    (if dev then "dev" else "production")
    Css.hash;
  Dream.run ~interface ~port
  @@ Dream.logger
  @@ Dream_encoding.compress
  @@ reload_script_middleware ~dev
  @@ cache_middleware ~dev
  @@ Dream.router
       [ Dream.get "/health" (fun _ -> Dream.html "OK")
       ; Dream.get "/" (fun _ -> Dream.html site)
       ; Dream.get "/index.html" (fun _ -> Dream.html site)
       ; Dream.get "/install" (fun request -> Dream.redirect request "/static/install")
       ; Dream.get "/static/**" @@ Dream.static "static"
       ]
;;