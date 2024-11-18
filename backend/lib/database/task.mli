type t =
  { description : string
  ; points : int
  ; recurrence_type : Types.Recurrence.t
  }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t

val get_users_tasks
  :  user_id:int
  -> (module Rapper_helper.CONNECTION)
  -> (t list, [> Caqti_error.call_or_retrieve ]) result

val insert_task
  :  user_id:int
  -> t
  -> (module Rapper_helper.CONNECTION)
  -> (unit, [> Caqti_error.call_or_retrieve ]) result
