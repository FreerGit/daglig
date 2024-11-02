open! Core

let connect ~sw ~env =
  (* TODO: fix this of course... *)
  let uri = Uri.of_string "postgresql://dev:dev@localhost:5432/dev" in
  match Caqti_eio_unix.connect_pool ~sw ~stdenv:env uri with
  | Ok conn -> conn
  | Error e ->
    raise_s
      [%message
        [%here] (sprintf "Did you forget docker instance?: %s" (Caqti_error.show e))]
;;

let run_with_pool pool ~f = Caqti_eio.Pool.use (fun conn -> f conn) pool
