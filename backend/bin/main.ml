open! Core
open! Lib

(* open Eio *)
open Eio.Std
open Result.Let_syntax

let main ~env ~sw =
  let pool = Database.Connection.connect ~sw ~env:(env :> Caqti_eio.stdenv) in
  let%bind _ =
    Database.Connection.run_with_pool pool ~f:Database.Migration.run_migrations
  in
  Ok (Lib.Server.run_server ~env ~sw pool)
;;

let () =
  Eio_main.run (fun env ->
    Switch.run (fun sw ->
      match main ~env ~sw with
      | Ok () -> ()
      | Error e -> traceln "Error: %s" (Caqti_error.show e)))
;;
