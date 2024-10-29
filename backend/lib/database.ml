open! Core

module Migration = struct
  open Caqti_request.Infix
  open Caqti_type.Std

  let create_users_table (module Conn : Caqti_eio.CONNECTION) =
    let query =
      (unit ->. unit)
      @@ {|
        CREATE TABLE IF NOT EXISTS users (
          user_id SERIAL PRIMARY KEY,
          email VARCHAR(255) UNIQUE NOT NULL,
          username VARCHAR(100),
          timezone VARCHAR(50),
          points INT DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        );
      |}
    in
    Conn.exec query ()
  ;;

  let create_oauth_users_table (module Conn : Caqti_eio.CONNECTION) =
    let query =
      (unit ->. unit)
      @@ {|
        CREATE TABLE IF NOT EXISTS oauth_accounts (
          oauth_id SERIAL PRIMARY KEY,                     
          user_id INT REFERENCES users(user_id) ON DELETE CASCADE,  
          provider VARCHAR(50) NOT NULL,                   
          provider_user_id VARCHAR(255) NOT NULL,          
          access_token TEXT,
          expires_at TIMESTAMP,
          UNIQUE(user_id, provider)
        );
      |}
    in
    Conn.exec query ()
  ;;

  let run_migrations (module Conn : Caqti_eio.CONNECTION) =
    let ( let* ) = Result.Let_syntax.( >>= ) in
    let* _ = create_users_table (module Conn) in
    let* _ = create_oauth_users_table (module Conn) in
    Ok ()
  ;;
end

module User = struct
  open Time_float_unix

  (* Not gonna lie, this is cool as fuck. *)
  module SQL_UTC = struct
    type t = Zone.t

    let t =
      let encode utc = Ok (Zone.to_string utc) in
      let decode str = Ok (Zone.of_string str) in
      Caqti_type.(custom ~encode ~decode string)
    ;;
  end

  type t =
    { email : string
    ; username : string
    ; timezone : SQL_UTC.t
    }

  let insert_user =
    [%rapper
      execute
        {sql| 
            INSERT INTO users VALUES
            (%string{email}, %string{username} %SQL_UTC{timezone})
          |sql}
        record_in]
  ;;
end

let%expect_test "SQL_UTC" =
  let open Time_float_unix in
  let default : User.SQL_UTC.t = Zone.utc in
  let plusone : User.SQL_UTC.t = Zone.of_utc_offset ~hours:1 in
  print_s @@ Zone.sexp_of_t default;
  print_s @@ Zone.sexp_of_t plusone;
  [%expect {|
    UTC
    UTC+1
    |}]
;;
