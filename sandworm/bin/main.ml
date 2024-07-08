open Sandworm

let s3 = "scaleway:dune-binary-distribution"
let artifacts = "./artifacts"
let file = "metadata.json"
let config_path = "./rclone.conf"

let () =
  let bundle = Metadata.import file in
  let daily_bundle = Metadata.(Bundle.create_daily Target.defaults) in
  let daily_bundle_date = Metadata.Bundle.get_data_string_from daily_bundle in
  let s3_daily_bundle = Format.sprintf "%s/%s" s3 daily_bundle_date in
  let () = Rclone.copy ~config_path artifacts s3_daily_bundle in
  let bundles = daily_bundle :: bundle in
  let () = Metadata.export "metadata.json" bundles in
  let () = Web.export_bundle_to_file ~file:"index.html" bundles in
  Format.printf "DONE :+1:"
;;
