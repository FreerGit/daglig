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
          provider_account_id VARCHAR(255) NOT NULL,          
          access_token TEXT,
          expires_at TIMESTAMP,
          UNIQUE(user_id, provider)
        );
      |}
  in
  Conn.exec query ()
;;

let create_task_table (module Conn : Caqti_eio.CONNECTION) =
  (* The INDEX is for faster querying of tasks that need reset *)
  let mk_table =
    (unit ->. unit)
    @@ {|
        CREATE TABLE IF NOT EXISTS tasks (
          task_id SERIAL PRIMARY KEY,
          user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
          description VARCHAR(200),
          points INT NOT NULL,
          recurrence_type VARCHAR(6) NOT NULL,
          last_reset_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          is_completed BOOLEAN NOT NULL DEFAULT FALSE,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      |}
  in
  let mk_index =
    (unit ->. unit)
    @@ {|
        CREATE INDEX IF NOT EXISTS idx_tasks_reset 
        ON tasks (user_id, recurrence_type, last_reset_at);
      |}
  in
  let ( let* ) = Result.Let_syntax.( >>= ) in
  let* _ = Conn.exec mk_table () in
  let* _ = Conn.exec mk_index () in
  Ok ()
;;

let run_migrations (module Conn : Caqti_eio.CONNECTION) =
  let ( let* ) = Result.Let_syntax.( >>= ) in
  let* _ = create_users_table (module Conn) in
  let* _ = create_oauth_users_table (module Conn) in
  let* _ = create_task_table (module Conn) in
  Ok ()
;;
