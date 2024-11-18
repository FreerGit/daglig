open! Core

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
           let ( let* ) = Result.Let_syntax.( >>= ) in
           let* _ = Conn.start () in
           let* _ = f (module Conn : Caqti_eio.CONNECTION) in
           let* _ = Conn.rollback () in
           Ok ())
         connection
     with
     | _ ->
       (try
          Caqti_eio.Pool.use
            (fun (module Conn : Caqti_eio.CONNECTION) -> Conn.rollback ())
            connection
        with
        | e ->
          print_s @@ Exn.sexp_of_t e;
          raise e))
;;

let run_insert_user_test =
  let open Lib.DB in
  let user : Lib.DB.User.t =
    { email = "email.."
    ; username = "name.."
    ; image = None
    ; timezone = Time_float_unix.Zone.utc
    }
  in
  (* Returns a function which composes multiple queries into a single transaction *)
  fun conn ->
    let ( let* ) = Result.Let_syntax.( >>= ) in
    let* _ = Migration.run_migrations conn in
    let* id = User.get_user_id_by_email ~email:user.email conn in
    assert (Option.is_none id);
    let* v = User.insert_user user conn in
    let* id = User.get_user_id_by_email ~email:user.email conn in
    Option.value_exn ~here:[%here] id
    |> fun id ->
    assert (id = v);
    let oauth : Oauth_account.t =
      { user_id = id
      ; provider = Github
      ; provider_account_id = "abcd"
      ; access_token = None
      ; expires_at = None
      }
    in
    Oauth_account.insert_or_update_oauth_account oauth conn
;;

let run_insert_and_get_tasks =
  let open Lib.DB in
  let user : Lib.DB.User.t =
    { email = "email.."
    ; username = "name.."
    ; image = None
    ; timezone = Time_float_unix.Zone.utc
    }
  in
  fun conn ->
    let ( let* ) = Result.Let_syntax.( >>= ) in
    let* _ = Migration.run_migrations conn in
    let* v = User.insert_user user conn in
    let* id = User.get_user_id_by_email ~email:user.email conn in
    Option.value_exn ~here:[%here] id
    |> fun id ->
    assert (id = v);
    let* empty_tasks = Task.get_users_tasks ~user_id:id conn in
    assert (List.is_empty empty_tasks);
    let tasks : Task.t list =
      [ { description = "ABC"; points = 10; recurrence_type = Types.Recurrence.Daily }
      ; { description = "DEF"; points = 20; recurrence_type = Types.Recurrence.Weekly }
      ; { description = "GHI"; points = 30; recurrence_type = Types.Recurrence.Daily }
      ]
    in
    (* ... insert all the tasks using Task.insert_task ... *)
    Eio.Fiber.all
      (List.map ~f:(fun task () -> ignore (Task.insert_task ~user_id:id task conn)) tasks);
    let* ts = Task.get_users_tasks ~user_id:id conn in
    assert (List.length ts = 3);
    Ok ()
;;

(* let* _ =  Task.insert_task *)

(* Main test runner *)
let run_all_tests ~stdenv ~uri =
  let tests =
    [ Lib.DB.Migration.run_migrations; run_insert_user_test; run_insert_and_get_tasks ]
  in
  let results = List.map ~f:(run_test ~stdenv ~uri) tests in
  let total = List.length results in
  List.iter
    ~f:(fun a ->
      match a with
      | Ok _ -> ()
      | Error a -> printf "%s\n" @@ Caqti_error.show a)
    results;
  let passed =
    List.fold_left
      ~f:(fun acc success -> if Result.is_ok success then acc + 1 else acc)
      ~init:0
      results
  in
  passed = total
;;

let test_db () =
  let uri = Uri.of_string "postgresql://test:test@localhost:5555/test" in
  Eio_main.run
  @@ fun stdenv ->
  (Alcotest.check Alcotest.bool)
    "is true"
    true
    (run_all_tests ~stdenv:(stdenv :> Caqti_eio.stdenv) ~uri)
;;

let () = Alcotest.run "DB suite" [ "DB", [ Alcotest.test_case "DB" `Quick test_db ] ]
