module Target : sig
  type t

  val to_human_readable_string : t -> string
  val to_description : t -> string
  val to_triple : t -> string * string * string
  val of_string : string -> t option
  val defaults : t list
end

module Bundle : sig
  type t

  val targets : t -> Target.t list
  val commit : t -> string
  val tag : t -> string option
  val to_download_file : Target.t -> string
  val to_download_url : base_url:string -> target:Target.t -> t -> string
  val to_certificate_url : base_url:string -> target:Target.t -> t -> string
  val get_date_string_from : ?prefix:string -> t -> string

  (* creates a bundle with the current date *)
  val create_daily : Target.t list -> commit:string -> tag:string option -> t

  (* returns [true] if the bundle matches the query *)
  val matches_criteria : tag:string option -> target:Target.t -> t -> bool

  (* returns the bundle with the highest version number *)
  val newest_tagged : t list -> t option
end

(* [import_from_json filename] reads the file and parses it into a list of [Bundle.t] *)
val import_from_json : string -> Bundle.t list

(* [export_to_json filename bundles] takes bundles and writes them to the specified
   file name. *)
val export_to_json : string -> Bundle.t list -> unit

(* Inserts a new bundle into the list unless there is already an equivalent one. *)
val insert_unique : Bundle.t -> Bundle.t list -> Bundle.t list
