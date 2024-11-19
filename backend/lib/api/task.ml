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
