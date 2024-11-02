open! Core
open Ppx_yojson_conv_lib.Yojson_conv

type t =
  { user_id : int option [@yojson.option]
  ; provider_account_id : string
  ; email : string
  ; name : string
  ; image : string option
  ; provider : Database.Types.Provider.t
  ; access_token : string option
  ; expires_at : Database.Types.SQL_TIMESTAMP.t option [@yojson.option]
  }
[@@deriving yojson]

let signup t pool =
  let open Result.Let_syntax in
  let open Database in
  let%bind user_exists =
    Connection.run_with_pool pool ~f:(User.get_user_id_by_email ~email:t.email)
  in
  let oauth_entry : Oauth_account.t =
    { user_id = 0 (* set below *)
    ; provider = t.provider
    ; provider_account_id = t.provider_account_id
    ; access_token = t.access_token
    ; expires_at = t.expires_at
    }
  in
  match user_exists with
  | Some user_id ->
    let entry = { oauth_entry with user_id } in
    let%bind _ =
      Connection.run_with_pool
        pool
        ~f:(Oauth_account.insert_or_update_oauth_account entry)
    in
    return user_id
  | None ->
    let new_user : User.t =
      { email = t.email
      ; username = t.name
      ; image = t.image
      ; timezone = Types.SQL_UTC.default
      }
    in
    let%bind user_id = Connection.run_with_pool pool ~f:(User.insert_user new_user) in
    let entry = { oauth_entry with user_id } in
    let%bind _ =
      Connection.run_with_pool pool ~f:(fun conn ->
        Oauth_account.insert_or_update_oauth_account entry conn)
    in
    return user_id
;;
