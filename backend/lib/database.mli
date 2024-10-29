module Migration : sig
  val create_users_table
    :  (module Caqti_eio.CONNECTION)
    -> (unit, [> Caqti_error.call_or_retrieve ]) result

  val create_oauth_users_table
    :  (module Caqti_eio.CONNECTION)
    -> (unit, [> Caqti_error.call_or_retrieve ]) result

  val run_migrations
    :  (module Caqti_eio.CONNECTION)
    -> (unit, [> Caqti_error.call_or_retrieve ]) result
end

module User : sig
  module SQL_UTC : sig
    type t = Time_float_unix.Zone.t

    val t : Time_float_unix.Zone.t Caqti_type.t
  end

  type t =
    { email : string
    ; username : string
    ; timezone : SQL_UTC.t
    }

  val insert_user
    :  t
    -> (module Rapper_helper.CONNECTION)
    -> (unit, [> Caqti_error.call_or_retrieve ]) result
end
