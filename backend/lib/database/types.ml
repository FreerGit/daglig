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
    | `String s -> Time_float_unix.of_string s
    | _ -> raise_s [%message [%here] (sprintf "Expected timestamp")]
  ;;

  let yojson_of_t t = `String (Time_float_unix.to_string t)
end

module Provider = struct
  type t =
    | GITHUB
    | GOOGLE
  [@@deriving show { with_path = false }, yojson]

  let t =
    let encode p = Ok (show p) in
    let decode str =
      match str with
      | "GITHUB" -> Ok GITHUB
      | "GOOGLE" -> Ok GOOGLE
      | _ -> Error "No such provider"
    in
    Caqti_type.(custom ~encode ~decode string)
  ;;
end
