module Server = struct
  let bucket_dir = "/dune/"
  let rclone_bucket_ref = Format.sprintf "dune-binary-distribution:%s" bucket_dir
  let url = "https://get.dune.build"
end

module Path = struct
  let artifacts_dir = "./artifacts"
  let metadata = "./metadata.json"
  let rclone = "./rclone.conf"
  let install = "./static/install"
  let html_index = "./static/index.html"
end
