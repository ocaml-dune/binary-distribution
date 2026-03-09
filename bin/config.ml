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

module Production : Configuration = struct
  module Server = struct
    let bucket_dir = "/dune/"
    let rclone_bucket_ref = Printf.sprintf "dune-binary-distribution:%s" bucket_dir
    let url = "https://get.dune.build/"
  end

  module Path = struct
    let artifacts_dir = "./artifacts"
    let metadata = "./metadata.json"
    let rclone = "./rclone.conf"
    let install = "./static/install"
  end
end

module Testing : Configuration = struct
  module Server = struct
    let bucket_dir = "/dune/test"
    let rclone_bucket_ref = Printf.sprintf "dune-binary-distribution:%s" bucket_dir
    let url = "https://get.dune.build/test"
  end

  module Path = struct
    let artifacts_dir = "./artifacts"
    let metadata = "./metadata.json"
    let rclone = "./rclone.conf"
    let install = "./static/install"
  end
end
