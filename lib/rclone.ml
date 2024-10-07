let run cmd args =
  let () = Format.printf "--> Execute cmd: %s@." cmd in
  let ic = Unix.open_process_args_in cmd args in
  let content = In_channel.input_all ic in
  match Unix.close_process_in ic with
  | Unix.WEXITED code when code = 0 -> Format.printf "%s" content
  | Unix.WEXITED code ->
    raise (Invalid_argument (Format.sprintf "--> Command exited with code %d" code))
  | Unix.WSIGNALED signal ->
    raise (Invalid_argument (Format.sprintf "--> Command killed by signal %d" signal))
  | Unix.WSTOPPED signal ->
    raise (Invalid_argument (Format.sprintf "--> Command stopped by signal %d" signal))
;;

(* It uses rclone copyto as it also allows us to copy one file if [src] points
   to a file. In case [src] is a directory, it behaves exactly like copy. *)
let copy ~config_path src dest =
  let cmd = "rclone" in
  let args =
    [| "rclone"
     ; "copyto"
     ; "-v"
     ; "--config"
     ; Unix.realpath config_path
     ; Unix.realpath src
     ; dest
    |]
  in
  run cmd args
;;
