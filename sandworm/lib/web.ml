module T = Tyxml.Html

let bucket_url ~url path = Format.sprintf "%s/%s" url path
let title = T.title (T.txt "Dune Binary Distribution")
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
let main_title = T.h1 [ T.txt "Dune binary distribution" ]

let motivation =
  [ T.h2 [ T.txt "Motivation" ]
  ; T.p
      [ T.txt
          "This website provides nightly releases of Dune, with the Developer Preview \
           features activated. These versions can be considered as unstable versions of \
           the Dune executable. Their purpose is to work without the need for opam and \
           as standalone executables. "
      ]
  ]
;;

let install =
  let targets =
    List.map
      (fun target -> T.li [ T.txt (Metadata.Target.to_string target) ])
      Metadata.Target.defaults
  in
  [ T.h2 [ T.txt "Installation" ]
  ; T.p [ T.txt "First, download the Dune binary associated with your system." ]
  ; T.p [ T.txt "You can download the latest binary with" ]
  ; T.pre
      [ T.code [ T.txt "$ curl -o dune https://download.dune.ci.dev/latest/<arch>/dune" ]
      ]
  ; T.p [ T.txt "where <arch> is one of the following targets:" ]
  ; T.ul targets
  ; T.p
      [ T.txt
          "Then, you can install Dune by running the following command from the location \
           where you downloaded the executable file:"
      ]
  ; T.pre [ T.code [ T.txt "$ chmod u+x ./dune\n$ sudo mv dune /usr/local/bin/dune" ] ]
  ; T.p
      [ T.txt "Note that you can ignore this command and move the "
      ; T.code [ T.txt "dune" ]
      ; T.txt " executable where you want, as long as it is accessible from the PATH."
      ]
  ; T.p
      [ T.txt "Check if the "
      ; T.code [ T.txt "dune" ]
      ; T.txt " executable is accessible by running"
      ]
  ; T.pre [ T.code [ T.txt "$ dune --help" ] ]
  ]
;;

let verify =
  [ T.h2 [ T.txt "Verify" ]
  ; T.p
      [ T.txt
          "To increase the trust in the builds, we generate a build certificate \
           associated with GitHub Actions where the binaries are built. Download the \
           certificate to verify the binary validates it:"
      ]
  ; T.pre
      [ T.code
          [ T.txt
              "$ curl https://download.dune.ci.dev/<yyyy-mm-dd>/<arch>/attestation.jsonl \
               -o attestation.jsonl"
          ]
      ]
  ; T.p
      [ T.txt "Using "
      ; T.code [ T.txt "gh" ]
      ; T.txt ", the GitHub CLI Tool, you can verify the certificate:"
      ]
  ; T.pre
      [ T.code
          [ T.txt
              "$ gh attestation verify ./dune -R tarides/dune-binary-distribution \
               --bundle ./attestation.jsonl"
          ]
      ]
  ]
;;

let target_html ~url ~has_certificate path target =
  let certificate =
    match has_certificate with
    | true ->
      let path = Fpath.(path / target / "attestation.jsonl" |> to_string) in
      let url = bucket_url ~url path |> T.Xml.uri_of_string in
      [ T.txt "- "
      ; T.a ~a:[ T.a_href url; T.a_class [ "certificate" ] ] [ T.txt "certificate" ]
      ]
    | false -> [ T.em ~a:[ T.a_class [ "certificate" ] ] [ T.txt "- no certificate" ] ]
  in
  let path = Fpath.(path / target / "dune" |> to_string) in
  let url = bucket_url ~url path |> T.Xml.uri_of_string in
  let name = Format.sprintf "dune-%s" target in
  T.li [ T.p (T.a ~a:[ T.a_href url ] [ T.txt name ] :: certificate) ]
;;

let bundle_html ~url ?title bundle =
  let open Metadata.Bundle in
  let date = get_date_string_from bundle in
  let h3_title =
    match title with
    | None -> Format.sprintf "%s" date
    | Some title -> title
  in
  let commit =
    match bundle.commit with
    | None -> T.txt ""
    | Some commit -> T.em [ T.txt @@ Format.sprintf " (commit: %s)" commit ]
  in
  let path = Fpath.v date in
  let targets = List.map Metadata.Target.to_string bundle.targets in
  let aux acc target =
    target_html ~url ~has_certificate:bundle.has_certificate path target :: acc
  in
  let targets = List.fold_left aux [] targets |> List.rev in
  T.div [ T.h3 [ T.txt h3_title; commit ]; T.ul targets ]
;;

let content ~url t =
  let bundles = List.map (bundle_html ~url) t in
  let bundles =
    if t <> [] then bundle_html ~url ~title:"Latest" (List.hd t) :: bundles else bundles
  in
  let body = (main_title :: motivation) @ install @ verify @ bundles in
  T.main body
;;

let export_bundle_to_file ~url ~file t =
  let page = T.html (T.head title headers) (T.body [ content ~url t; plausible_js ]) in
  let file_handle = open_out file in
  let fmt = Format.formatter_of_out_channel file_handle in
  Format.fprintf fmt "%a@." (T.pp ~indent:false ()) page;
  close_out file_handle
;;
