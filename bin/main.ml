open Sandworm
open Cmdliner

module Common_args = struct
  let metadata_file =
    let doc = "The JSON file containing the metadata." in
    Arg.(value & opt (some string) None & info ~doc [ "metadata" ])
  ;;

  let commit =
    let doc = "The build commit hash." in
    Arg.(required & opt (some string) None & info ~doc [ "c"; "commit" ])
  ;;

  let tag =
    let doc = "The build tag." in
    Arg.(value & opt (some string) None & info ~doc [ "tag" ])
  ;;

  let dry_run =
    let doc = "Simulate the command execution" in
    Arg.(value & flag & info ~doc [ "n"; "dry-run" ])
  ;;

  let dev =
    let doc = "Active development features" in
    Arg.(value & flag & info ~doc [ "dev" ])
  ;;

  let port =
    let doc = "Specify a port for the web server" in
    Arg.(value & opt int 8080 & info ~doc [ "p"; "port" ])
  ;;
end

module Sync = struct
  let synchronise metadata_file ~commit ~tag dry_run =
    Format.printf "--> Start synchronisation\n";
    let bundles = Metadata.import_from_json metadata_file in
    let daily_bundle =
      Metadata.Bundle.create_daily ~commit ~tag Metadata.Target.defaults
    in
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
        Filename.concat
          Config.Server.rclone_bucket_ref
          (Filename.basename Config.Path.install)
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
    let bundles = Metadata.insert_unique daily_bundle bundles in
    let () =
      if dry_run
      then Format.printf "- Export metadata to %s\n" metadata_file
      else Metadata.export_to_json metadata_file bundles
    in
    Format.printf "--> Completed ✓\n"
  ;;

  let term =
    let open Term.Syntax in
    let+ metadata_file = Common_args.metadata_file
    and+ commit = Common_args.commit
    and+ tag = Common_args.tag
    and+ dry_run = Common_args.dry_run in
    let metadata_file =
      match metadata_file with
      | Some metadata_file -> metadata_file
      | None ->
        (match tag with
         | Some _ -> Config.Path.metadata_stable
         | None -> Config.Path.metadata_nightly)
    in
    synchronise metadata_file ~commit ~tag dry_run
  ;;

  let info =
    let doc = "Update the metadata and push the binaries." in
    Cmd.info "sync" ~doc
  ;;

  let cmd = Cmd.v info term
end

module Http = struct
  let serve dev port =
    let title = "Dune Nightly" in
    let base_url = Config.Server.url in
    let bundles =
      Metadata.import_from_json Config.Path.metadata_stable
      @ Metadata.import_from_json Config.Path.metadata_nightly
    in
    let routes =
      let main_page = Web.generate_main_page ~title ~base_url bundles in
      Web.Route.empty
      |> Web.Route.add ~path:"/" main_page
      |> Web.Route.add ~path:"/index.html" main_page
    in
    Server.serve ~dev ~base_url routes port bundles
  ;;

  let term =
    let open Term.Syntax in
    let+ dev = Common_args.dev
    and+ port = Common_args.port in
    serve dev port
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
  let cmd = Cmd.group ~default:root_term info [ Sync.cmd; Http.cmd ] in
  Cmd.eval cmd |> exit
;;
