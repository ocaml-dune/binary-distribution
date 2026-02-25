module type FILE = sig
  val file_name : string
end

module Production : FILE = struct
  let file_name = "config-production.toml"
end

module type Configuration = sig
  module Server : sig
    val rclone_bucket_ref : string
    val url : string
  end

  module Path : sig
    val artifacts_dir : string
    val metadata : string
    val rclone : string
    val install : string
  end
end

module Make (F : FILE) : Configuration = struct
  let toml_data =
    match Toml.Parser.from_filename F.file_name with
    | `Ok v -> v
    | `Error (s, _location) -> failwith s
  ;;

  let get_or_fail section' key' =
    match
      Toml.Lenses.(get toml_data (key section' |-- table |-- key key' |-- string))
    with
    | Some v -> v
    | None ->
      failwith (Printf.sprintf "Config file is missing a value for %s.%s" section' key')
  ;;

  module Server = struct
    let section = get_or_fail "server"
    let bucket_dir = section "bucket_dir"
    let rclone_bucket_ref = Printf.sprintf "dune-binary-distribution:%s" bucket_dir
    let url = section "url"
  end

  module Path = struct
    let section = get_or_fail "path"
    let artifacts_dir = section "artifacts_dir"
    let metadata = section "metadata"
    let rclone = section "rclone"
    let install = section "install"
  end
end
