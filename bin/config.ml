module Server = struct
  let bucket_dir = "/dune/"
  let rclone_bucket_ref = Format.sprintf "dune-binary-distribution:%s" bucket_dir
  let artifact_base_url = "https://get.dune.build"
end

module Site = struct
  let install_script_url = "https://nightly.dune.build/install"
end

module Path = struct
  let artifacts_dir = "./artifacts"
  let metadata = "./metadata.json"
  let rclone = "./rclone.conf"
  let install = "./static/install"
end
