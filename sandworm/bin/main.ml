open Sandworm

let main commit has_certificate =
  let () = Format.printf "--> Start to build website\n" in
  let bundle = Metadata.import_from_json Config.metadata_file in
  let daily_bundle =
    Metadata.(Bundle.create_daily ~commit ~has_certificate Target.defaults)
  in
  let daily_bundle_date = Metadata.Bundle.get_data_string_from daily_bundle in
  let s3_daily_bundle = Filename.concat Config.s3_bucket_ref daily_bundle_date in
  let () =
    Rclone.copy ~config_path:Config.rclone_path Config.artifacts_path s3_daily_bundle
  in
  let bundles = daily_bundle :: bundle in
  let () = Metadata.export_to_json Config.metadata_file bundles in
  let () =
    Web.export_bundle_to_file ~url:Config.s3_public_url ~file:Config.html_path bundles
  in
  Format.printf "--> Export completed ✓\n"
;;

open Cmdliner

let info = Cmd.info "sandworm"

let term =
  let open Term.Syntax in
  let+ commit =
    let doc = "The build commit hash." in
    Arg.(value & opt (some string) None & info ~doc [ "c"; "commit" ])
  and+ has_certificate =
    let doc = "Indicate that the build produced a certificate." in
    Arg.(value & flag & info ~doc [ "with-certificate" ])
  in
  main commit has_certificate
;;

let () =
  let cmd = Cmd.v info term in
  Cmd.eval cmd |> exit
;;
