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
    ; has_certificate : (bool[@default false])
    ; commit : (string option[@default None])
    }
  [@@deriving yojson]

  let create ~date ~commit ~has_certificate targets =
    { date; targets; commit; has_certificate }
  ;;

  let create_daily targets =
    let date = Unix.time () |> Ptime.of_float_s |> Option.get |> Ptime.to_date in
    create ~date targets
  ;;

  let get_data_string_from t =
    let y, m, d = t.date in
    Format.sprintf "%d-%02d-%02d" y m d
  ;;
end

type t = Bundle.t list [@@deriving yojson]

let import_from_json file : t = Yojson.Safe.from_file file |> of_yojson |> Result.get_ok
let export_to_json file t = to_yojson t |> Yojson.Safe.to_file file
