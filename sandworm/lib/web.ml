module T = Tyxml.Html

let bucket_url ~url path = Format.sprintf "%s/%s" url path
let title = T.title (T.txt "Dune Dev Preview")
let css = T.link ~rel:[ `Stylesheet ] ~href:"main.css" ()

let plausible_js =
  T.script
    ~a:
      [ T.Unsafe.string_attrib "data-domain" "dune.ci.dev"
      ; T.a_defer ()
      ; T.a_src
          (T.Xml.uri_of_string "https://plausible.ci.dev/js/script.file-downloads.js")
      ]
    (T.txt "")
;;

let headers = [ css ]
let main_title = T.h2 [ T.txt "Dune binary distribution" ]

let install =
  [ T.p
      [ T.txt "First, download the dune binary associated with your system requirement." ]
  ; T.p
      [ T.txt
          "Then, you can install Dune by running the following command from the location \
           where you downloaded the executable file:"
      ]
  ; T.pre [ T.code [ T.txt "$ sudo mv dune /usr/local/bin/dune" ] ]
  ; T.p
      [ T.txt
          "Note that you can ignore this command and move the dune executable where you \
           want, as long as it is accessible from the PATH."
      ]
  ]
;;

let target_html ~url path target =
  let path = Fpath.(path / target / "dune" |> to_string) in
  let url = bucket_url ~url path |> T.Xml.uri_of_string in
  let name = Format.sprintf "dune-%s" target in
  T.li [ T.a ~a:[ T.a_href url ] [ T.txt name ] ]
;;

let bundle_html ~url bundle =
  let open Metadata.Bundle in
  let date = get_data_string_from bundle in
  let h3_title = Format.sprintf "Preview %s" date in
  let path = Fpath.v date in
  let targets = List.map Metadata.Target.to_string bundle.targets in
  let aux acc target = target_html ~url path target :: acc in
  let targets = List.fold_left aux [] targets |> List.rev in
  T.div [ T.h3 [ T.txt h3_title ]; T.ul targets ]
;;

let content ~url t =
  let bundles = List.map (bundle_html ~url) t in
  let body = (main_title :: install) @ bundles in
  T.main body
;;

let export_bundle_to_file ~url ~file t =
  let page = T.html (T.head title headers) (T.body [ content ~url t; plausible_js ]) in
  let file_handle = open_out file in
  let fmt = Format.formatter_of_out_channel file_handle in
  Format.fprintf fmt "%a@." (T.pp ~indent:true ()) page;
  close_out file_handle
;;
