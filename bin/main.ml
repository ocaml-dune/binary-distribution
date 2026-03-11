open Sandworm
open Cmdliner

module Common_args = struct
  let testing =
    let doc = "Run in test configuration." in
    Arg.(value & opt bool false & info ~doc [ "testing" ])
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
  let synchronise (module Config : Config.Configuration) ~commit ~tag dry_run =
    Format.printf "--> Start synchronisation\n";
    let bundles = Metadata.import_from_json Config.Path.metadata in
    let daily_bundle =
      Metadata.Bundle.create_daily ~commit ~tag Metadata.Target.defaults
    in
    let bundle_key =
      match daily_bundle.tag with
      | Some tag -> tag
      | None -> Metadata.Bundle.get_date_string_from daily_bundle
    in
    let s3_bundle_dir = Filename.concat Config.Server.rclone_bucket_ref bundle_key in
    let () =
      if dry_run
      then
        Format.printf
          "- Copy files from path (%s) to %s, using RClone (%s)\n"
          Config.Path.artifacts_dir
          s3_bundle_dir
          Config.Path.rclone
      else
        Rclone.copy
          ~config_path:Config.Path.rclone
          Config.Path.artifacts_dir
          s3_bundle_dir
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
      then Format.printf "- Export metadata to %s\n" Config.Path.metadata
      else Metadata.export_to_json Config.Path.metadata bundles
    in
    Format.printf "--> Completed ✓\n"
  ;;

  let term =
    let open Term.Syntax in
    let+ testing = Common_args.testing
    and+ commit = Common_args.commit
    and+ tag = Common_args.tag
    and+ dry_run = Common_args.dry_run in
    let config =
      match testing with
      | false -> (module Config.Production : Config.Configuration)
      | true -> (module Config.Testing)
    in
    synchronise config ~commit ~tag dry_run
  ;;

  let info =
    let doc = "Update the metadata and push the binaries." in
    Cmd.info "sync" ~doc
  ;;

  let cmd = Cmd.v info term
end

module Http = struct
  let serve dev (module Config : Config.Configuration) port =
    let title = "Dune Nightly" in
    let base_url = Config.Server.url in
    let bundles = Metadata.import_from_json Config.Path.metadata in
    let latest_release =
      match Metadata.Bundle.newest_tagged bundles with
      | None -> "<RELEASE>"
      | Some bundle ->
        (* guaranteed to exist at this point *)
        Option.get bundle.tag
    in
    let routes =
      let main_page = Web.generate_main_page ~title ~base_url ~latest_release bundles in
      Web.Route.empty
      |> Web.Route.add ~path:"/" main_page
      |> Web.Route.add ~path:"/index.html" main_page
    in
    Server.serve ~dev ~base_url routes port bundles
  ;;

  let term =
    let open Term.Syntax in
    let+ dev = Common_args.dev
    and+ testing = Common_args.testing
    and+ port = Common_args.port in
    let config =
      match testing with
      | false -> (module Config.Production : Config.Configuration)
      | true -> (module Config.Testing)
    in
    serve dev config port
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
