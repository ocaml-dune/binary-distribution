open Tyxml.Html

let bucket_url path =
  Format.sprintf "https://dune-binary-distribution.s3.fr-par.scw.cloud/%s" path
;;

let title = title (txt "Dune Dev Preview")
let css = link ~rel:[ `Stylesheet ] ~href:"main.css" ()

let plausible_js =
  script
    ~a:
      [ Tyxml.Html.Unsafe.string_attrib "data-domain" "dune.ci.dev"
      ; a_defer ()
      ; a_src (Xml.uri_of_string "https://plausible.ci.dev/js/script.file-downloads.js")
      ]
    (txt "")
;;

let headers = [ css ]
let main_title = h2 [ txt "Dune distribution binary" ]

let install =
  [ p
      [ txt
          "After downloaded and extracted, you could use the command below to install it."
      ]
  ; pre [ code [ txt "$ sudo mv dune /usr/local/bin/dune" ] ]
  ; p [ txt "Feel free to move the executable wherever you want!" ]
  ]
;;

let target_html path target =
  let path = Fpath.(path / target / "dune" |> to_string) in
  let url = bucket_url path |> Xml.uri_of_string in
  let name = Format.sprintf "dune-%s" target in
  li [ a ~a:[ a_href url ] [ txt name ] ]
;;

let bundle_html bundle =
  let open Metadata.Bundle in
  let date = get_data_string_from bundle in
  let h3_title = Format.sprintf "Preview %s" date in
  let path = Fpath.v date in
  let targets = List.map Metadata.Target.to_string bundle.targets in
  let aux acc target = target_html path target :: acc in
  let targets = List.fold_left aux [] targets |> List.rev in
  div [ h3 [ txt h3_title ]; ul targets ]
;;

let content t =
  let bundles = List.map bundle_html t in
  let body = (main_title :: install) @ bundles in
  main body
;;

let export_bundle_to_file ~file t =
  let page = html (head title headers) (body [ content t; plausible_js ]) in
  let file_handle = open_out file in
  let fmt = Format.formatter_of_out_channel file_handle in
  Format.fprintf fmt "%a@." (pp ~indent:true ()) page;
  close_out file_handle
;;
