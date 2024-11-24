open! Core
open Piaf

let add_task email (task : Database.Task.t) pool =
  let user_id =
    Database.Connection.run_with_pool pool ~f:(Database.User.get_user_id_by_email ~email)
  in
  match user_id with
  | Error _ -> Response.create `Unauthorized
  | Ok user_id ->
    print_s ([%sexp_of: int option] user_id);
    (match user_id with
     | None -> Response.create `Unauthorized
     | Some user_id ->
       print_endline "fdasf";
       let f =
         Database.Task.insert_task_query
           ~user_id
           ~description:task.description
           ~points:task.points
           ~recurrence_type:task.recurrence_type
       in
       (match Database.Connection.run_with_pool pool ~f with
        | Error e ->
          Logs.info (fun m -> m "%s" (Caqti_error.show e));
          Response.create `Internal_server_error
        | Ok _ -> Response.create `OK))
;;

let get_tasks email pool =
  let headers =
    Headers.of_list [ "connection", "close"; "content-type", "application/json" ]
  in
  let user_id =
    Database.Connection.run_with_pool pool ~f:(Database.User.get_user_id_by_email ~email)
  in
  match user_id with
  | Error e ->
    Logs.info (fun m -> m "%s %s" [%here].pos_fname (Caqti_error.show e));
    Response.create `Unauthorized
  | Ok None -> Response.create `Unauthorized
  | Ok (Some user_id) ->
    print_endline "fdas";
    let f = Database.Task.get_users_tasks ~user_id in
    (match Database.Connection.run_with_pool pool ~f with
     | Error e ->
       Logs.info (fun m -> m "%s %s" [%here].pos_fname (Caqti_error.show e));
       Response.create `Internal_server_error
     | Ok tasks ->
       let tasks_json = List.map ~f:Database.Task.yojson_of_t tasks in
       Response.of_string ~headers ~body:(Yojson.Safe.to_string (`List tasks_json)) `OK)
;;
