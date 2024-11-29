open! Core
open Piaf

let add_task user_id (task : Database.Task.t) pool =
  let f =
    Database.Task.insert_task_query
      ~user_id
      ~description:task.description
      ~points:task.points
      ~recurrence_type:task.recurrence_type
  in
  match Database.Connection.run_with_pool pool ~f with
  | Error e ->
    Logs.info (fun m -> m "%s" (Caqti_error.show e));
    Response.create `Unauthorized
  | Ok _ -> Response.create `OK
;;

let get_tasks user_id pool =
  let headers =
    Headers.of_list [ "connection", "close"; "content-type", "application/json" ]
  in
  let f = Database.Task.get_users_tasks ~user_id in
  match Database.Connection.run_with_pool pool ~f with
  | Error e ->
    Logs.info (fun m -> m "%s %s" [%here].pos_fname (Caqti_error.show e));
    Response.create `Unauthorized
  | Ok tasks ->
    let tasks_json = List.map ~f:Database.Task.yojson_of_t tasks in
    Response.of_string ~headers ~body:(Yojson.Safe.to_string (`List tasks_json)) `OK
;;

let update_task user_id (task : Database.Task.t) pool =
  let f =
    Database.Task.update_task_query
      ~description:task.description
      ~points:task.points
      ~recurrence_type:task.recurrence_type
      ~task_id:task.task_id
      ~user_id
  in
  match Database.Connection.run_with_pool pool ~f with
  | Error e ->
    Logs.info (fun m -> m "%s %s" [%here].pos_fname (Caqti_error.show e));
    Response.create `Unauthorized
  | Ok () -> Response.create `OK
;;

let remove_task user_id task_id pool =
  let f = Database.Task.remove_task_query ~user_id ~task_id in
  match Database.Connection.run_with_pool pool ~f with
  | Error e ->
    Logs.info (fun m -> m "%s %s" [%here].pos_fname (Caqti_error.show e));
    Response.create `Unauthorized
  | Ok () -> Response.create `OK
;;
