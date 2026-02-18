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

let matching_bundle ~base_url bundles ~target ~tag request =
  let module Bundle = Sandworm.Metadata.Bundle in
  let bundle =
    List.find_opt
      (fun candidate -> Bundle.matches_criteria ~tag ~target candidate)
      bundles
  in
  match bundle with
  | None -> Dream.respond ~status:`Not_Found "No such release"
  | Some bundle ->
    Dream.redirect request (Bundle.to_download_url ~base_url ~target bundle)
;;

let latest_route_from_targets ~base_url bundles request =
  let module Target = Sandworm.Metadata.Target in
  let target = Dream.param request "target" in
  match Target.of_string target with
  | None -> Dream.respond ~status:`Not_Found "Invalid target"
  | Some target -> matching_bundle bundles ~base_url ~target ~tag:None request
;;

let stable_release ~base_url bundles request =
  let module Target = Sandworm.Metadata.Target in
  let release = Dream.param request "release" in
  let target = Dream.param request "target" in
  match Target.of_string target with
  | None -> Dream.respond ~status:`Not_Found "Invalid target"
  | Some target -> matching_bundle bundles ~base_url ~target ~tag:(Some release) request
;;

let error_template _error _debug_info suggested_response =
  let status = Dream.status suggested_response in
  let code = Dream.status_to_int status in
  let reason = Dream.status_to_string status in
  Dream.set_header suggested_response "Content-Type" Dream.text_html;
  let title = Printf.sprintf "Dune - Error %d (%s)" code reason in
  let open Lwt.Syntax in
  let+ body = Dream.body suggested_response in
  let body = Sandworm.Web.generate_error_page ~title body in
  Dream.set_body suggested_response body;
  suggested_response
;;

let from_tuple_to_dream page =
  List.map (fun (path, content) -> Dream.get path (fun _ -> Dream.html content)) page
;;

let serve ~dev ~base_url routes port bundles =
  let interface = if dev then "127.0.0.1" else "0.0.0.0" in
  let error_handler = Dream.error_template error_template in
  Dream.log
    "Server is up and running with mode %s and with css %s"
    (if dev then "dev" else "production")
    Css.hash;
  Dream.run ~interface ~port ~error_handler
  @@ Dream.logger
  @@ reload_script_middleware ~dev
  @@ cache_middleware ~dev
  @@ Dream.router
       (from_tuple_to_dream routes
        @ [ Dream.get "/health" (fun _ -> Dream.html "OK")
          ; Dream.get "/install" (fun request -> Dream.redirect request "/static/install")
          ; Dream.get "/static/**" @@ Dream.static "static"
          ; Dream.get "/latest/:target" (latest_route_from_targets ~base_url bundles)
          ; Dream.get "/stable/:release/:target" (stable_release ~base_url bundles)
          ])
;;
