open Sandworm
open Cmdliner

module Common_args = struct
  let html_file =
    let doc = "The file where to export the HTML code." in
    Arg.(value & opt string Config.Path.html_index & info ~doc [ "html" ])
  ;;

  let metadata_file =
    let doc = "The JSON file to import the data from." in
    Arg.(value & opt string Config.Path.metadata & info ~doc [ "metadata" ])
  ;;

  let commit =
    let doc = "The build commit hash." in
    Arg.(value & opt (some string) None & info ~doc [ "c"; "commit" ])
  ;;

  let dry_run =
    let doc = "Simulate the command executation" in
    Arg.(value & flag & info ~doc [ "n"; "dry-run" ])
  ;;

  let dev =
    let doc = "Enable develoment mode" in
    Arg.(value & flag & info ~doc [ "dev" ])
  ;;

  let port =
    let doc = "Specify a port for the web server" in
    Arg.(value & opt int 8080 & info ~doc [ "p"; "port" ])
  ;;
end

module Gen_html = struct
  let generate_website html_file metadata_file =
    Format.printf "--> Generate the index %s\n" html_file;
    let bundles = Metadata.import_from_json metadata_file in
    Web.export_bundle_to_file ~base_url:Config.Server.url ~file:html_file bundles;
    Format.printf "--> Completed ✓\n"
  ;;

  let term =
    let open Term.Syntax in
    let+ html_file = Common_args.html_file
    and+ metadata_file = Common_args.metadata_file in
    generate_website html_file metadata_file
  ;;

  let info =
    let doc = "Generate the website HTML code from metadata to a file." in
    Cmd.info "gen-html" ~doc
  ;;

  let cmd = Cmd.v info term
end

module Sync = struct
  let synchronise html_file metadata_file commit dry_run =
    Format.printf "--> Start synchronisation\n";
    let bundle = Metadata.import_from_json metadata_file in
    let daily_bundle = Metadata.(Bundle.create_daily ~commit Target.defaults) in
    let daily_bundle_date = Metadata.Bundle.get_date_string_from daily_bundle in
    let s3_daily_bundle =
      Filename.concat Config.Server.rclone_bucket_ref daily_bundle_date
    in
    let () =
      if dry_run
      then
        Format.printf
          "- Copy files from path (%s) to %s, using RClone (%s)\n"
          Config.Path.artifacts_dir
          s3_daily_bundle
          Config.Path.rclone
      else
        Rclone.copy
          ~config_path:Config.Path.rclone
          Config.Path.artifacts_dir
          s3_daily_bundle
    in
    let () =
      let install_bucket_path =
        Filename.concat Config.Server.rclone_bucket_ref Config.Path.install
      in
      if dry_run
      then
        Format.printf
          "- Copy file (%s) to %s, using RClone (%s)\n"
          Config.Path.install
          install_bucket_path
          Config.Path.rclone
      else
        Rclone.copy
          ~config_path:Config.Path.rclone
          Config.Path.install
          install_bucket_path
    in
    let bundles = Metadata.insert_unique daily_bundle bundle in
    let () =
      if dry_run
      then Format.printf "- Export metadata to %s\n" metadata_file
      else Metadata.export_to_json metadata_file bundles
    in
    let () =
      if dry_run
      then Format.printf "- Export HTML code to %s\n" html_file
      else Web.export_bundle_to_file ~base_url:Config.Server.url ~file:html_file bundles
    in
    Format.printf "--> Completed ✓\n"
  ;;

  let term =
    let open Term.Syntax in
    let+ html_file = Common_args.html_file
    and+ metadata_file = Common_args.metadata_file
    and+ commit = Common_args.commit
    and+ dry_run = Common_args.dry_run in
    match commit with
    | None -> failwith "Commit is mandatory"
    | Some commit -> synchronise html_file metadata_file commit dry_run
  ;;

  let info =
    let doc = "Update the metadata, push the binaries and, update the index.html file." in
    Cmd.info "sync" ~doc
  ;;

  let cmd = Cmd.v info term
end

module Http = struct
  let serve dev metadata_file port =
    let bundles = Metadata.import_from_json metadata_file in
    let content = Web.export_bundle_to_string ~base_url:Config.Server.url bundles in
    Server.serve ~dev content port
  ;;

  let term =
    let open Term.Syntax in
    let+ dev = Common_args.dev
    and+ port = Common_args.port
    and+ metadata_file = Common_args.metadata_file in
    serve dev metadata_file port
  ;;

  let info =
    let doc = "Run the HTTP server and expose the content on a specific port." in
    Cmd.info "serve" ~doc
  ;;

  let cmd = Cmd.v info term
end

let info = Cmd.info "sandworm"
let root_term = Term.ret (Term.const (`Help (`Pager, None)))

let () =
  let cmd = Cmd.group ~default:root_term info [ Sync.cmd; Gen_html.cmd; Http.cmd ] in
  Cmd.eval cmd |> exit
;;
