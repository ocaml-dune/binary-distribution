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

  let to_human_readable_string = function
    | Aarch64_apple_darwin -> "Apple macOS (ARM64)"
    | X86_64_apple_darwin -> "Apple macOS (x86-64)"
    | X86_64_unknown_linux_musl -> "Linux (amd64, MUSL)"
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

  let to_targz_file target =
    let name = to_string target in
    Format.sprintf "dune-%s.tar.gz" name
  ;;

  let defaults = [ Aarch64_apple_darwin; X86_64_apple_darwin; X86_64_unknown_linux_musl ]
end

module Bundle = struct
  type pdate = Ptime.date

  let pdate_of_yojson json =
    json
    |> [%of_yojson: float]
    |> Result.map (fun f -> Ptime.of_float_s f |> Option.get |> Ptime.to_date)
  ;;

  let pdate_to_yojson pdate =
    Ptime.of_date pdate |> Option.get |> Ptime.to_float_s |> [%to_yojson: float]
  ;;

  type t =
    { date : pdate
    ; targets : Target.t list
    ; has_certificate : bool [@default false]
    ; commit : string [@default "-"]
    }
  [@@deriving yojson]

  let create ~date ~commit targets = { date; targets; commit; has_certificate = true }

  let create_daily targets =
    let date = Unix.time () |> Ptime.of_float_s |> Option.get |> Ptime.to_date in
    create ~date targets
  ;;

  let get_date_string_from ?prefix t =
    let y, m, d = t.date in
    let date = Format.sprintf "%d-%02d-%02d" y m d in
    match prefix with
    | None -> date
    | Some prefix -> prefix ^ date
  ;;

  let equal b1 b2 =
    let p1 = Ptime.of_date b1.date |> Option.get in
    let p2 = Ptime.of_date b2.date |> Option.get in
    Ptime.equal p1 p2
  ;;

  let ( / ) = Filename.concat

  let to_url ~base_url ~target t =
    base_url / get_date_string_from t / Target.to_string target
  ;;

  let to_certificate_url ~base_url ~target t =
    to_url ~base_url ~target t / "attestation.jsonl"
  ;;

  let download_file_name ~target = Target.to_targz_file target

  (* TODO: use the right URL *)
  let to_download_url ~base_url ~target t =
    to_url ~base_url ~target t / download_file_name ~target
  ;;
end

type t = Bundle.t list [@@deriving yojson]

let insert_unique bundle = function
  | [] -> [ bundle ]
  | bundle_checked :: bs as bundles ->
    if Bundle.equal bundle bundle_checked then bundle :: bs else bundle :: bundles
;;

let import_from_json file : t = Yojson.Safe.from_file file |> of_yojson |> Result.get_ok
let export_to_json file t = to_yojson t |> Yojson.Safe.to_file file
