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
  [@@deriving show { with_path = false }]

  let yojson_of_t = function
    | Github -> `String "github"
    | Google -> `String "google"
  ;;

  let t_of_yojson = function
    | `String "github" -> Github
    | `String "google" -> Google
    | _ -> raise_s [%message [%here] (sprintf "Expected Provider.t")]
  ;;

  let t =
    let encode = function
      | Github -> Ok "github"
      | Google -> Ok "google"
    in
    let decode = function
      | "github" -> Ok Github
      | "google" -> Ok Google
      | _ -> Error "No such provider"
    in
    Caqti_type.(custom ~encode ~decode string)
  ;;
end
