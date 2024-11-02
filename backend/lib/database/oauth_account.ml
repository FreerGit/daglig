open! Core
open Ppx_yojson_conv_lib.Yojson_conv

type t =
  { user_id : int
  ; provider : Types.Provider.t
  ; provider_account_id : string
  ; access_token : string option
  ; expires_at : Types.SQL_TIMESTAMP.t option
  }
[@@deriving yojson]

let insert_or_update_oauth_account =
  [%rapper
    execute
      {sql| 
          INSERT INTO oauth_accounts (user_id, provider, provider_account_id, access_token, expires_at)
          VALUES (%int{user_id}, %Types.Provider{provider}, %string{provider_account_id}, %string?{access_token}, %Types.SQL_TIMESTAMP?{expires_at})
          ON CONFLICT (user_id, provider) DO UPDATE SET
            provider_account_id = EXCLUDED.provider_account_id,
            access_token = EXCLUDED.access_token,
            expires_at = EXCLUDED.expires_at
        |sql}
      record_in]
;;
