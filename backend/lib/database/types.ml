open! Core

module SQL_UTC = struct
  open Time_float_unix

  type t = Zone.t

  let t =
    let encode utc = Ok (Zone.to_string utc) in
    let decode str = Ok (Zone.of_string str) in
    Caqti_type.(custom ~encode ~decode string)
  ;;

  let t_of_yojson json =
    match json with
    | `String s -> Zone.of_string s
    | _ -> raise_s [%message [%here] (sprintf "Expected timestamp")]
  ;;

  let yojson_of_t t = `String (Zone.to_string t)
  let default = Zone.utc
end

module SQL_TIMESTAMP = struct
  type t = Time_float_unix.t

  let t =
    let encode utc = Ok (Time_float_unix.to_string utc) in
    let decode str = Ok (Time_float_unix.of_string str) in
    Caqti_type.(custom ~encode ~decode string)
  ;;

  let t_of_yojson json =
    match json with
    | `Int timestamp ->
      Time_float_unix.Span.of_sec (Float.of_int timestamp)
      |> Time_float_unix.of_span_since_epoch
    | _ -> raise_s [%message [%here] (sprintf "Expected timestamp")]
  ;;

  let yojson_of_t t = `String (Time_float_unix.to_string t)
end

module Provider = struct
  type t =
    | Github
    | Google
  [@@deriving yojson]

  let t_of_yojson = function
    | `String "github" -> Github
    | `String "Github" -> Github
    | `String "google" -> Google
    | `String "Google" -> Google
    | _ -> raise_s [%message [%here] (sprintf "Expected Provider.t")]
  ;;

  let yojson_of_t = function
    | Github -> `String "Github"
    | Google -> `String "Google"
  ;;

  let t =
    let encode = function
      | Github -> Ok "Github"
      | Google -> Ok "Google"
    in
    let decode = function
      | "Github" -> Ok Github
      | "Google" -> Ok Google
      | _ -> Error "No such provider"
    in
    Caqti_type.(custom ~encode ~decode string)
  ;;
end

module Recurrence = struct
  type t =
    | Daily
    | Weekly
  [@@deriving sexp]

  let t_of_yojson = function
    | `String "Daily" -> Daily
    | `String "Weekly" -> Weekly
    | _ -> raise_s [%message [%here] (sprintf "Expected Recurrence.t")]
  ;;

  let yojson_of_t = function
    | Daily -> `String "Daily"
    | Weekly -> `String "Weekly"
  ;;

  let t =
    let encode = function
      | Daily -> Ok "Daily"
      | Weekly -> Ok "Weekly"
    in
    let decode = function
      | "Daily" -> Ok Daily
      | "Weekly" -> Ok Weekly
      | _ -> Error "No such provider"
    in
    Caqti_type.(custom ~encode ~decode string)
  ;;
end

let%expect_test "SQL_UTC" =
  let d = Recurrence.Daily in
  let w = Recurrence.Weekly in
  let daily = Yojson.Safe.to_string (Recurrence.yojson_of_t d) in
  let weekly = Yojson.Safe.to_string (Recurrence.yojson_of_t w) in
  print_endline daily;
  print_endline weekly;
  [%expect {|
    "Daily"
    "Weekly"
    |}]
;;
