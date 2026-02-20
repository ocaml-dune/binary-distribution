module Target = struct
  type t =
    | Aarch64_apple_darwin
    | X86_64_apple_darwin
    | X86_64_unknown_linux_musl
  [@@deriving yojson]

  let to_string = function
    | Aarch64_apple_darwin -> "aarch64-apple-darwin"
    | X86_64_apple_darwin -> "x86_64-apple-darwin"
    | X86_64_unknown_linux_musl -> "x86_64-unknown-linux-musl"
  ;;

  let of_string = function
    | "aarch64-apple-darwin" -> Some Aarch64_apple_darwin
    | "x86_64-apple-darwin" -> Some X86_64_apple_darwin
    | "x86_64-unknown-linux-musl" -> Some X86_64_unknown_linux_musl
    | _ -> None
  ;;

  let to_human_readable_string = function
    | Aarch64_apple_darwin -> "Apple macOS (ARM64)"
    | X86_64_apple_darwin -> "Apple macOS (x86-64)"
    | X86_64_unknown_linux_musl -> "Linux (x86-64, musl)"
  ;;

  let to_description = function
    | Aarch64_apple_darwin -> "macOS 11 or later for Apple Sillicon processors"
    | X86_64_apple_darwin -> "macOS 11 or later for Intel processors"
    | X86_64_unknown_linux_musl -> "Linux for Intel 64-bit processors"
  ;;

  let to_triple = function
    | Aarch64_apple_darwin -> "aarch64", "apple", "macOS"
    | X86_64_apple_darwin -> "x86-64", "apple", "macOS"
    | X86_64_unknown_linux_musl -> "x86-64", "unknown", "Linux"
  ;;

  let defaults = [ Aarch64_apple_darwin; X86_64_apple_darwin; X86_64_unknown_linux_musl ]
end

module Pdate = struct
  type t = Ptime.date

  let of_yojson json =
    json
    |> [%of_yojson: float]
    |> Result.map (fun f -> Ptime.of_float_s f |> Option.get |> Ptime.to_date)
  ;;

  let to_yojson pdate =
    Ptime.of_date pdate |> Option.get |> Ptime.to_float_s |> [%to_yojson: float]
  ;;

  let equal (l : t) (r : t) =
    let y, m, d = l in
    let y', m', d' = r in
    Int.equal y y' && Int.equal m m' && Int.equal d d'
  ;;
end

module Bundle = struct
  type t =
    { date : Pdate.t
    ; targets : Target.t list
    ; has_certificate : bool [@default false]
    ; commit : string [@default "-"]
    ; tag : string option [@default None]
    }
  [@@deriving yojson]

  let create ~date ~commit ~tag targets =
    { date; targets; commit; tag; has_certificate = true }
  ;;

  let create_daily targets =
    let date = Unix.time () |> Ptime.of_float_s |> Option.get |> Ptime.to_date in
    create ~date targets
  ;;

  let matches_criteria ~tag ~target t =
    let t =
      match tag, t.tag with
      | None, None -> Some t
      | Some l, Some r when String.equal l r -> Some t
      | _, _ -> None
    in
    match t with
    | None -> false
    | Some t -> List.mem target t.targets
  ;;

  let get_date_string_from ?prefix t =
    let y, m, d = t.date in
    let date = Format.sprintf "%d-%02d-%02d" y m d in
    match prefix with
    | None -> date
    | Some prefix -> prefix ^ date
  ;;

  let equal l r = Pdate.equal l.date r.date && Option.equal String.equal l.tag r.tag
  let ( / ) = Filename.concat
  let to_nightly_url ~base_url ~target ~date = base_url / date / Target.to_string target
  let to_stable_url ~base_url ~target ~tag = base_url / tag / Target.to_string target

  let to_certificate_url ~base_url ~target t =
    let date = get_date_string_from t in
    to_nightly_url ~base_url ~target ~date / "attestation.jsonl"
  ;;

  let download_nightly_name ~date arch =
    (* TODO: why can the date be missing? *)
    match date with
    | None -> Format.sprintf "dune-%s.tar.gz" arch
    | Some date -> Format.sprintf "dune-%s-%s.tar.gz" date arch
  ;;

  let download_stable_name ~tag arch = Printf.sprintf "dune-%s-%s.tar.gz" tag arch

  let to_download_url ~base_url ~target t =
    let date = get_date_string_from t in
    let arch = Target.to_string target in
    match t.tag with
    | None ->
      to_nightly_url ~base_url ~target ~date
      / download_nightly_name ~date:(Some date) arch
    | Some tag -> to_stable_url ~base_url ~target ~tag / download_stable_name ~tag arch
  ;;

  let to_download_file target =
    let arch = Target.to_string target in
    download_nightly_name ~date:None arch
  ;;
end

type t = Bundle.t list [@@deriving yojson]

let insert_unique bundle = function
  | [] -> [ bundle ]
  | bundle_checked :: bs as bundles ->
    if Bundle.equal bundle bundle_checked then bundle :: bs else bundle :: bundles
;;

let import_from_json file : t = Yojson.Safe.from_file file |> of_yojson |> Result.get_ok

let export_to_json file t =
  Out_channel.with_open_bin file (fun oc ->
    t |> to_yojson |> Yojson.Safe.pretty_to_channel oc)
;;
