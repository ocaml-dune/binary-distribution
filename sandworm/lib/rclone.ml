let copy ~config_path src dest =
  let cmd = "rclone" in
  let args = [ "copy"; "-v"; "--config"; config_path; src; dest ] in
  let cmd = Filename.quote_command cmd args in
  let ret = Sys.command cmd in
  if ret > 0
  then raise (Invalid_argument (Format.sprintf "cmd exit with code %d" ret))
  else ()
;;
