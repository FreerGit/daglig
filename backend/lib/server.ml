open! Core
open Piaf
(* open Ppx_yojson_conv_lib.Yojson_conv *)

let get_body_string body =
  match Body.to_string body with
  | Ok s -> s
  | _ -> raise_s [%message [%here] (sprintf "Expected json")]
;;

(* TODO clean this up ffs *)
let connection_handler (params : Request_info.t Server.ctx) pool =
  match params.request with
  | { Request.meth = `POST; target; body; headers; _ } ->
    let path = Uri.of_string target |> Uri.path in
    print_endline path;
    (match path with
     | "/api/proxy/signup" ->
       let json = get_body_string body in
       Logs.info (fun m -> m "%s" json);
       let oauth_user = Api.Signup.t_of_yojson (Yojson.Safe.from_string json) in
       let user_id = Api.Signup.signup oauth_user pool in
       (match user_id with
        | Error e ->
          Logs.err (fun m -> m "%s" (Caqti_error.show e));
          Response.create `Internal_server_error
        | Ok r -> r)
     | "/api/proxy/add-task" ->
       let json = get_body_string body in
       let user_id =
         Headers.get headers "X-User-ID" |> Option.bind ~f:Int.of_string_opt
       in
       let task = Database.Task.t_of_yojson (Yojson.Safe.from_string json) in
       (match user_id with
        | None -> Response.create `Unauthorized
        | Some user_id ->
          Logs.info (fun m -> m "%s" json);
          Api.Task.add_task user_id task pool)
     | _ -> Response.create `Not_found)
  | { Request.meth = `GET; target; headers; _ } ->
    let path = Uri.of_string target |> Uri.path in
    (match path with
     | "/get-tasks" ->
       let user_id =
         Headers.get headers "X-User-ID" |> Option.bind ~f:Int.of_string_opt
       in
       (match user_id with
        | None -> Response.create `Unauthorized
        | Some user_id -> Api.Task.get_tasks user_id pool)
     | "/abc" -> Response.create `OK
     | _ -> Response.create `Not_found)
  | { Request.meth = `PUT; target; body; headers; _ } ->
    let path = Uri.of_string target |> Uri.path in
    (match path with
     | "/update-task" ->
       let json = get_body_string body in
       let user_id =
         Headers.get headers "X-User-ID" |> Option.bind ~f:Int.of_string_opt
       in
       let task = Database.Task.t_of_yojson (Yojson.Safe.from_string json) in
       (match user_id with
        | None -> Response.create `Unauthorized
        | Some user_id -> Api.Task.update_task user_id task pool)
     | _ -> Response.create `Not_found)
  | _ -> Response.create `Method_not_allowed
;;

let run ~sw ~host ~port env pool =
  let domains = Stdlib.Domain.recommended_domain_count () in
  let config =
    Server.Config.create ~buffer_size:0x1000 ~domains ~backlog:1024 (`Tcp (host, port))
  in
  let server = Server.create ~config (fun h -> connection_handler h pool) in
  let command = Server.Command.start ~sw env server in
  command
;;

let start ~sw env conn =
  let host = Eio.Net.Ipaddr.V4.loopback in
  run ~sw ~host ~port:8000 env conn
;;

let setup_log ?style_renderer level =
  Logs_threaded.enable ();
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level ~all:true level;
  Logs.set_reporter (Logs_fmt.reporter ())
;;

let run_server ~env ~sw pool =
  setup_log (Some Info);
  let _command = start ~sw env pool in
  ()
;;
