let run_test ~stdenv ~uri f =
  Eio.Switch.run
  @@ fun sw ->
  let connector = Caqti_eio_unix.connect_pool ~sw ~stdenv uri in
  match connector with
  | Error err ->
    let open Core in
    raise_s
      [%message
        [%here]
          (sprintf
             "Connection error, did you forget to turn on docker instance?: %s"
             (Caqti_error.show err))]
  | Ok connection ->
    (* Run a test case through a transaction and roll it back at the end
       this gives the nice property of the test cases not mutating the db*)
    (try
       Caqti_eio.Pool.use
         (fun (module Conn : Caqti_eio.CONNECTION) ->
           Conn.start () |> Result.get_ok;
           f (module Conn : Caqti_eio.CONNECTION) |> Result.get_ok;
           Conn.rollback () |> Result.get_ok;
           Ok ())
         connection
       |> Result.is_ok
     with
     | _ ->
       (try
          Caqti_eio.Pool.use
            (fun (module Conn : Caqti_eio.CONNECTION) -> Conn.rollback ())
            connection
          |> Result.get_ok
        with
        | _ -> ());
       false)
;;

(* Main test runner *)
let run_all_tests ~stdenv ~uri =
  let tests = [ Lib.Database.Migration.run_migrations ] in
  let results = List.map (run_test ~stdenv ~uri) tests in
  let total = List.length results in
  let passed =
    List.fold_left (fun acc success -> if success then acc + 1 else acc) 0 results
  in
  passed = total
;;

let test_db () =
  let uri = Uri.of_string "postgresql://dev:dev@localhost:5432/dev" in
  Eio_main.run
  @@ fun stdenv ->
  (Alcotest.check Alcotest.bool)
    "is true"
    true
    (run_all_tests ~stdenv:(stdenv :> Caqti_eio.stdenv) ~uri)
;;

let () = Alcotest.run "DB suite" [ "DB", [ Alcotest.test_case "DB" `Quick test_db ] ]
