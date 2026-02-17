module Server : sig
  val rclone_bucket_ref : string
  val artifact_base_url : string
end

module Site : sig
  val install_script_url : string
end

module Path : sig
  val artifacts_dir : string
  val metadata_nightly : string
  val metadata_stable : string
  val rclone : string
end
