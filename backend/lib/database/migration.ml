open! Core
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
