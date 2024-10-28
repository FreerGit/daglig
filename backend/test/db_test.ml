(* open Eio.Std *)

module type DB_TRANSACTION = sig
  val name : string
  val run : (module Caqti_eio.CONNECTION) -> unit
end

let run_test ~stdenv ~uri (module Test : DB_TRANSACTION) =
  Eio.Switch.run
  @@ fun sw ->
  let connector = Caqti_eio_unix.connect ~sw ~stdenv uri in
  match connector with
  | Error err ->
    Printf.printf "Connection error in test '%s': %s\n" Test.name (Caqti_error.show err);
    false
  | Ok connection ->
    (try
       (* Start transaction *)
       let (module Conn : Caqti_eio.CONNECTION) = connection in
       Conn.start () |> Result.get_ok;
       (* Run the test *)
       Test.run (module Conn);
       (* Always rollback, even if test succeeds *)
       Conn.rollback () |> Result.get_ok;
       Printf.printf "Test '%s' completed successfully\n" Test.name;
       true
     with
     | exn ->
       Printf.printf
         "Test '%s' failed with exception: %s\n"
         Test.name
         (Printexc.to_string exn);
       (* Ensure rollback happens even on exception *)
       (try
          let (module Conn : Caqti_eio.CONNECTION) = connection in
          Conn.rollback () |> Result.get_ok
        with
        | _ -> ());
       false)
;;

type user =
  { username : string
  ; email : string
  }

(* Function to execute the CREATE TABLE command *)
let create_users_table (module Conn : Caqti_eio.CONNECTION) =
  let open Caqti_request.Infix in
  let open Caqti_type.Std in
  let query =
    (unit ->. unit)
    @@ {|
    CREATE TABLE IF NOT EXISTS users (
      username VARCHAR(100) NOT NULL,
      email VARCHAR(100) NOT NULL UNIQUE
    );
  |}
  in
  Conn.exec query ()
;;

module CreateTable = struct
  let name = "check if table exists"

  let insert_user =
    [%rapper
      execute
        {sql| 
          INSERT INTO users VALUES
          (%string{username}, %string{email})
        |sql}
        record_in]
  ;;

  let get_users =
    [%rapper
      get_many
        {sql| 
          SELECT @string{username}, @string{email}
          FROM users 
        |sql}
        record_out]
  ;;

  let run (module Conn : Caqti_eio.CONNECTION) =
    let created = create_users_table (module Conn) in
    (* throws? *)
    Result.get_ok created;
    let user = { email = "email.."; username = "name..." } in
    let i = insert_user user (module Conn) in
    let g = get_users () (module Conn) in
    assert (Result.is_ok i);
    assert (Result.is_ok g)
  ;;
end

(* Main test runner *)
let run_all_tests ~stdenv ~uri =
  let tests = [ (module CreateTable : DB_TRANSACTION) ] in
  let results = List.map (run_test ~stdenv ~uri) tests in
  let total = List.length results in
  let passed =
    List.fold_left (fun acc success -> if success then acc + 1 else acc) 0 results
  in
  passed = total
;;

(* ENV POSTGRES_DB = dev ENV POSTGRES_USER = dev ENV POSTGRES_PASSWORD = dev *)

(* let create_uri () =
  let dev = "dev" in
  let host = "localhost" in
  (* Adjust this if needed *)
  let port = 5432 in
  (* Default PostgreSQL port *)
  let uri_str = Printf.sprintf "postgresql://%s:%s@%s:%d/%s" dev dev host port dev in
  let u = Uri.of_string uri_str in
  print_endline "HERE";
  print_endline @@ Uri.to_string u;
  u
;; *)

(* Table creation query as a string *)

let test_db () =
  (* let uri = create_uri () in *)
  let uri = Uri.of_string "postgresql://dev:dev@localhost:5432/dev" in
  Eio_main.run
  @@ fun stdenv ->
  (Alcotest.check Alcotest.bool)
    "is true"
    true
    (run_all_tests ~stdenv:(stdenv :> Caqti_eio.stdenv) ~uri)
;;

let () = Alcotest.run "DB suite" [ "DB", [ Alcotest.test_case "DB" `Quick test_db ] ]
