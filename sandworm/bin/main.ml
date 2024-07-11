open Sandworm

let () =
let () = Format.printf "--> Start to build website\n" in
  let bundle = Metadata.import_from_json Config.metadata_file in
  let daily_bundle = Metadata.(Bundle.create_daily Target.defaults) in
  let daily_bundle_date = Metadata.Bundle.get_data_string_from daily_bundle in
  let s3_daily_bundle = Format.sprintf "%s/%s" Config.s3_bucket_ref daily_bundle_date in
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
