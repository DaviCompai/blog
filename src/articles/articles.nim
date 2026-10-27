import std/[json, options,htmlparser,xmltree,times,sysrand, strutils, base64]

import mummy, mummy/routers
import mummy_utils
import marvdown
import nimja/parser

import tiny_sqlite

import ../utilities/[db_utils, markdown_utils,login_utils]

var language = ""

proc renderArticlesPage(title:string = "Davi Compai's Blog",language:string = "pt-br"): string =
  compiletemplatefile("articles/index.nimja",basedir = getscriptdir() / "../templates")

proc showArticlesPage*(request: Request) =
  resp renderArticlesPage()

proc renderMakePostPage(languages:seq[tuple[language_display: string,language_id: int]],title:string = "Criar post",language:string = "pt-br"): string =
  compiletemplatefile("articles/create_article.nimja",basedir = getscriptdir() / "../templates")

proc showMakePostPage*(request: Request) =
  var languages: seq[tuple[language_display: string, language_id: int]] = @[]


  for row in db.iterate("SELECT concat(name,'-',country),id FROM languages"):
    languages.add(row.unpack((string, int)))
  resp renderMakePostPage(languages)

proc PostArticle*(request: Request) =
  let title = @"title"
  let content_md = @"content"
  let language_id = @"language"

  let content_html = markdownToHtml(content_md)
  let content_pure = parseHtml(content_html).innerText()

  db.exec("INSERT INTO posts (language_id, title, content_md,content_html,content_pure) VALUES (?,?,?,?)",language_id,title,content_md,content_html,content_pure)
  # showMakePostPage(request)
  redirect(request.uri)

proc renderLoginPage(title:string = "Login",language:string = "pt-br"): string =
  compiletemplatefile("articles/login.nimja",basedir = getscriptdir() / "../templates")

proc showLoginPage*(request: Request) =
  debugEcho(isLogged(request))
  debugEcho(LoggedAs(request))
  resp renderLoginPage()

proc generateApiKey(byteLength: int = 32): string =
  let randomBytes = urandom(byteLength)
  result = encode(randomBytes)

proc PostLogin*(request: Request) =
  var headers: HttpHeaders
  let user = @"user"
  let password = @"password"
  let user_row = db.one("SELECT password FROM auth WHERE user = ?;",user)


  # TODO: fazer procs de utils para login (testar se está logado, retornar booleano, usando a chave de api)
  if user_row.isSome():
    let right_password = user_row.get[0].strVal
    if password == right_password:
      let api_key = generateApiKey()

      db.exec("DELETE FROM auth_codes WHERE expires_at < datetime('now');")
      db.exec("INSERT INTO auth_codes (code,user) VALUES (?,?);",api_key,user)

      let expiryDate = (now() + 7.days).utc
      setCookie("auth_code", api_key, expires = expiryDate)
  redirect(request.uri)
