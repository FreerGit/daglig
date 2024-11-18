open! Core
open Ppx_yojson_conv_lib.Yojson_conv

type t =
  { description : string
  ; points : int
  ; recurrence_type : Types.Recurrence.t
  }
[@@deriving yojson]

let get_users_tasks =
  [%rapper
    get_many
      {sql| 
          SELECT (@string{description}, @int{points}, 
                  @Types.Recurrence{recurrence_type}) 
                  FROM tasks WHERE user_id = %int{user_id}
          |sql}
      record_out]
;;

let insert_task_query =
  [%rapper
    execute
      {sql| 
            INSERT INTO tasks (user_id, description, points, reccurence_type)
            VALUES (%int{user_id}, %string{description}, %int{points}, 
                  %Types.Recurrence{recurrence_type}) 
          |sql}]
;;

let insert_task ~user_id task conn =
  insert_task_query
    ~user_id
    ~description:task.description
    ~points:task.points
    ~recurrence_type:task.recurrence_type
    conn
;;
