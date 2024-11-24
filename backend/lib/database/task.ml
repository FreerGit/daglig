open! Core
open Ppx_yojson_conv_lib.Yojson_conv

type t =
  { description : string
  ; recurrence_type : Types.Recurrence.t
  ; points : int
  ; task_id : int
  }
[@@deriving yojson]

let get_users_tasks =
  [%rapper
    get_many
      {sql| 
          SELECT @string{description}, @int{points}, 
                 @Types.Recurrence{recurrence_type}, @int{task_id}
          FROM tasks WHERE user_id = %int{user_id}
          |sql}
      record_out]
;;

let insert_task_query =
  [%rapper
    execute
      {sql| 
            INSERT INTO tasks (user_id, description, points, recurrence_type)
            VALUES (%int{user_id}, %string{description}, %int{points}, 
                  %Types.Recurrence{recurrence_type}) 
          |sql}]
;;

let update_task_query =
  [%rapper
    execute
      {sql| 
          UPDATE tasks 
          SET description = %string{description},
              points = %int{points},
              recurrence_type = %Types.Recurrence{recurrence_type}
          WHERE task_id = %int{task_id}
          AND user_id = %int{user_id}
      |sql}]
;;
