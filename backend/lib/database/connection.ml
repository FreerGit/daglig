open! Core

let connect ~sw ~env =
  (* TODO: fix this of course... *)
  let uri = Uri.of_string "postgresql://dev:dev@localhost:5432/dev" in
  let pool_config = Caqti_pool_config.create ~max_size:8 () in
  match Caqti_eio_unix.connect_pool ~sw ~stdenv:env ~pool_config uri with
  | Ok conn -> conn
  | Error e ->
    raise_s
      [%message
        [%here] (sprintf "Did you forget docker instance?: %s" (Caqti_error.show e))]
;;

let run_with_pool pool ~f =
  try Caqti_eio.Pool.use (fun conn -> f conn) pool with
  | Postgresql.Error e ->
    raise_s [%message "Postgresql error" ~error_msg:(Postgresql.string_of_error e)]
  | exn ->
    raise_s
      [%message [%here] ~error:(Exn.to_string exn) ~backtrace:(Printexc.get_backtrace ())]
;;
