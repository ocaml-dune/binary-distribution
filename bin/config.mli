module Server : sig
  val rclone_bucket_ref : string
  val url : string
end

module Path : sig
  val artifacts_dir : string
  val metadata_nightly : string
  val metadata_stable : string
  val rclone : string
  val install : string
end
