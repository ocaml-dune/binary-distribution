let livereload ~dev inner_handler request =
  if dev then Dream.livereload inner_handler request else inner_handler request
;;

let serve ?(dev = false) site port =
  Dream.log "Server is up and running with mode %s" (if dev then "dev" else "production");
  Dream.run ~port
  @@ Dream.logger
  @@ livereload ~dev
  @@ Dream.router
       [ Dream.get "/health" (fun _ -> Dream.html "OK")
       ; Dream.get "/" (fun _ -> Dream.respond site)
       ; Dream.get "/index.html" (fun _ -> Dream.respond site)
       ; Dream.get "/install" (fun request -> Dream.redirect request "/static/install")
       ; Dream.get "/static/**" @@ Dream.static "static"
       ]
;;
