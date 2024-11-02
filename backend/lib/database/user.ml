open! Core
open Ppx_yojson_conv_lib.Yojson_conv

type t =
  { email : string
  ; username : string
  ; image : string option
  ; timezone : Types.SQL_UTC.t
  }
[@@deriving yojson]

let get_user_id_by_email =
  [%rapper
    get_opt
      {sql| 
            SELECT (@int{user_id}) FROM users WHERE email = %string{email}
          |sql}]
;;

let insert_user =
  [%rapper
    get_one
      {sql| 
            INSERT INTO users (email, username, image, timezone)
            VALUES (%string{email}, %string{username}, %string?{image}, %Types.SQL_UTC{timezone})
            RETURNING (@int{user_id})
          |sql}
      record_in]
;;

let%expect_test "SQL_UTC" =
  let open Time_float_unix in
  let default : Types.SQL_UTC.t = Zone.utc in
  let plusone : Types.SQL_UTC.t = Zone.of_utc_offset ~hours:1 in
  print_s @@ Zone.sexp_of_t default;
  print_s @@ Zone.sexp_of_t plusone;
  [%expect {|
    UTC
    UTC+1
    |}]
;;
