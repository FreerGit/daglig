module Migration : sig
  val create_users_table
    :  (module Caqti_eio.CONNECTION)
    -> (unit, [> Caqti_error.call_or_retrieve ]) result

  val create_oauth_users_table
    :  (module Caqti_eio.CONNECTION)
    -> (unit, [> Caqti_error.call_or_retrieve ]) result

  val run_migrations : sw:Eio.Switch.t -> stdenv:Caqti_eio.stdenv -> uri:Uri.t -> unit
end
