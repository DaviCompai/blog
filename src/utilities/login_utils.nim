import mummy, mummy/routers
import mummy_utils

import tiny_sqlite
import ../utilities/db_utils

proc isLogged*(request: Request): bool =
  if not (request.cookies.hasKey("auth_code")):
    return false
  let api_key = request.cookies("auth_code")
  db.exec("DELETE FROM auth_codes WHERE expires_at < datetime('now');")
  let user_row = db.one("SELECT user FROM auth_codes WHERE code = ?;",api_key)
  if not (user_row.isSome):
    return false
  # user_row.get[0].strVal
    

  return true

proc LoggedAs*(request: Request): string =
  if not (request.cookies.hasKey("auth_code")):
    return ""
  let api_key = request.cookies("auth_code")
  db.exec("DELETE FROM auth_codes WHERE expires_at < datetime('now');")
  let user_row = db.one("SELECT user FROM auth_codes WHERE code = ?;",api_key)
  if not (user_row.isSome):
    return ""
  return user_row.get[0].strVal

