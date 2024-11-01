open! Core
open Piaf
open Eio.Std
open Ppx_yojson_conv_lib.Yojson_conv

module P = struct
  type t =
    { foo : string
    ; bar : int
    }
  [@@deriving yojson]
end

let connection_handler (params : Request_info.t Server.ctx) =
  let headers =
    Headers.of_list [ "connection", "close"; "content-type", "application/json" ]
  in
  match params.request with
  | { Request.meth = `GET; target; _ } ->
    let path = Uri.of_string target |> Uri.path in
    (match path with
     | "/api/proxy/signup" ->
       let p = P.yojson_of_t @@ { foo = "hej"; bar = 2 } in
       let s = Yojson.Safe.to_string p in
       Response.of_string ~body:s `OK
     | _ -> Response.create `Not_found)
  | _ -> Response.create ~headers `Method_not_allowed
;;

let run ~sw ~host ~port env handler =
  let domains = Stdlib.Domain.recommended_domain_count () in
  let config = Server.Config.create ~buffer_size:0x1000 ~domains (`Tcp (host, port)) in
  let server = Server.create ~config handler in
  let command = Server.Command.start ~sw env server in
  command
;;

let start ~sw env =
  let host = Eio.Net.Ipaddr.V4.loopback in
  run ~sw ~host ~port:8000 env connection_handler
;;

(* let setup_log ?style_renderer level =
   Logs_threaded.enable ();
   Fmt_tty.setup_std_outputs ?style_renderer ();
   Logs.set_level ~all:true level;
   Logs.set_reporter (Logs_fmt.reporter ())
   ;; *)

let run_server () =
  (* setup_log (Some Info); *)
  Eio_main.run (fun env ->
    Switch.run (fun sw ->
      let _command = start ~sw env in
      ()))
;;
