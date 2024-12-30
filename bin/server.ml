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

let latest_route_from_targets ~base_url bundle =
  let open Sandworm.Metadata in
  List.map
    (fun target ->
      let path = Format.sprintf "/%s" (Target.to_string target) in
      Dream.get path (fun request ->
        Dream.redirect request (Bundle.to_download_url ~base_url ~target bundle)))
    bundle.targets
;;

let error_template _error _debug_info suggested_response =
  let open Sandworm in
  let status = Dream.status suggested_response in
  let code = Dream.status_to_int status in
  let reason = Dream.status_to_string status in
  Dream.set_header suggested_response "Content-Type" Dream.text_html;
  Dream.set_body
    suggested_response
    (Web.generate_error_page ~title:"Dune - Error 404" ~code reason);
  Lwt.return suggested_response
;;

let from_tuple_to_dream page =
  List.map (fun (path, content) -> Dream.get path (fun _ -> Dream.html content)) page
;;

let serve ~dev ~base_url routes port bundle =
  let interface = if dev then "127.0.0.1" else "0.0.0.0" in
  let error_handler = Dream.error_template error_template in
  Dream.log
    "Server is up and running with mode %s and with css %s"
    (if dev then "dev" else "production")
    Css.hash;
  Dream.run ~interface ~port ~error_handler
  @@ Dream.logger
  @@ Dream_encoding.compress
  @@ reload_script_middleware ~dev
  @@ cache_middleware ~dev
  @@ Dream.router
       (from_tuple_to_dream routes
        @ [ Dream.get "/health" (fun _ -> Dream.html "OK")
          ; Dream.get "/install" (fun request -> Dream.redirect request "/static/install")
          ; Dream.get "/static/**" @@ Dream.static "static"
          ; Dream.scope "/latest" [] (latest_route_from_targets ~base_url bundle)
          ])
;;
