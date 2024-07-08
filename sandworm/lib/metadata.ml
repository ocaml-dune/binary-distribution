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
  type t =
    { date : Ptime.date
    ; targets : Target.t list
    }

  let create ~date targets = { date; targets }

  let create_daily targets =
    let date = Unix.time () |> Ptime.of_float_s |> Option.get |> Ptime.to_date in
    create ~date targets
  ;;

  let get_data_string_from t =
    let y, m, d = t.date in
    Format.sprintf "%d-%02d-%02d" y m d
  ;;
end

module Json = struct
  type obj =
    { date : float
    ; targets : Target.t list
    }
  [@@deriving yojson]

  type t = obj list [@@deriving yojson]

  let obj_to_bundle obj =
    let date = Ptime.of_float_s obj.date |> Option.get |> Ptime.to_date in
    let targets = obj.targets in
    Bundle.create ~date targets
  ;;

  let bundle_to_obj (bundle : Bundle.t) =
    let date = Ptime.of_date bundle.date |> Option.get |> Ptime.to_float_s in
    let targets = bundle.targets in
    { date; targets }
  ;;

  let to_bundle : t -> Bundle.t list = List.map obj_to_bundle
  let of_bundle : Bundle.t list -> t = List.map bundle_to_obj
  let import file : t = Yojson.Safe.from_file file |> of_yojson |> Result.get_ok
  let export file t = to_yojson t |> Yojson.Safe.to_file file
end

type t = Bundle.t list

let import file = Json.(import file |> to_bundle)
let export file t = Json.(of_bundle t |> export file)
