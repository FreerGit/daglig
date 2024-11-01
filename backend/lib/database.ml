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
          image VARCHAR(255),
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
    ; image : string option
    ; timezone : SQL_UTC.t
    }

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
            VALUES (%string{email}, %string{username}, %string?{image}, %SQL_UTC{timezone})
            RETURNING (@int{user_id})
          |sql}
        record_in]
  ;;
end

module UserOAuth = struct
  (* Define the UserOAuth type *)
  module Provider = struct
    type t =
      | GITHUB
      | GOOGLE
    [@@deriving show { with_path = false }]

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

  type t =
    { user_id : int
    ; provider : Provider.t
    ; provider_user_id : string
    ; access_token : string option
    ; expires_at : Time_float_unix.t
    }

  module SQL_TIMESTAMP = struct
    type t = Time_float_unix.t

    let t =
      let encode utc = Ok (Time_float_unix.to_string utc) in
      let decode str = Ok (Time_float_unix.of_string str) in
      Caqti_type.(custom ~encode ~decode string)
    ;;
  end

  (* Insert function for user_oauth *)
  let insert_user_oauth =
    [%rapper
      execute
        {sql| 
          INSERT INTO oauth_accounts (user_id, provider, provider_user_id, access_token, expires_at)
          VALUES (%int{user_id}, %Provider{provider}, %string{provider_user_id}, %string?{access_token}, %SQL_TIMESTAMP{expires_at})
          ON CONFLICT (user_id, provider) DO UPDATE SET
            provider_user_id = EXCLUDED.provider_user_id,
            access_token = EXCLUDED.access_token,
            expires_at = EXCLUDED.expires_at
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
