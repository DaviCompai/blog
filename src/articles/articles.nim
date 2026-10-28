import std/[json, options,htmlparser,xmltree,times,sysrand, strutils, base64,unicode]

import mummy, mummy/routers
import mummy_utils

import marvdown

import nimja/parser

import unislug

import tiny_sqlite

import ../utilities/[db_utils, markdown_utils,login_utils]

import normalize

var language = ""

proc renderArticlesPage(title:string = "Davi Compai's Blog",language:string = "pt-br"): string =
  compiletemplatefile("articles/index.nimja",basedir = getscriptdir() / "../templates")

proc showArticlesPage*(request: Request) =
  resp renderArticlesPage()

proc renderMakePostPage(languages:seq[tuple[language_display: string,language_id: int]],title:string = "Criar post",language:string = "pt-br"): string =
  compiletemplatefile("articles/create_article.nimja",basedir = getscriptdir() / "../templates")

proc showMakePostPage*(request: Request) =
  var languages: seq[tuple[language_display: string, language_id: int]] = @[]

  if not isLogged(request):
    redirect("/login")
  for row in db.iterate("SELECT concat(name,'-',country),id FROM languages"):
    languages.add(row.unpack((string, int)))
  resp renderMakePostPage(languages)

proc PostArticle*(request: Request) =
  if not isLogged(request):
    redirect("/login")
  let title = @"title"
  let content_md = @"content"
  debugEcho(content_md)
  let language_id = @"language"

  let content_html = markdownToHtml(content_md)
  let content_pure = parseHtml(content_html).innerText()
  {.gcsafe.}:
    let slug = slugify(title)

  db.exec("INSERT INTO posts (language_id, title, content_md,content_html,content_pure,slug) VALUES (?,?,?,?,?,?)",language_id,title,content_md,content_html,content_pure,slug)
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

proc removeDiacritics(s: string): string =
  result = ""
  # Iterate over each rune in its Normalization Form D (Decomposed) representation
  for r in toNFD(s):
    # Filter out combining diacritical marks (Unicode block U+0300 to U+036F)
    let intVal = r.int
    if intVal < 0x0300 or intVal > 0x036F:
      result.add($r)

proc renderArticle(title:string = "Login",language:string = "pt-br",content_html:string): string =
  compiletemplatefile("articles/article.nimja",basedir = getscriptdir() / "../templates")

proc getArticle*(request:Request) =
  let article_sluggified_name = @"article_name"
  let article_info = db.one("""
  SELECT posts.title,
        posts.content_html,
        concat(l.name,'-',l.country) AS language
  FROM posts
  join languages l on posts.language_id = l.id
  WHERE slug = ?;
  """,article_sluggified_name)

  let title = article_info.get[0].strVal
  let content_html = article_info.get[1].strVal
  let language = article_info.get[2].strVal

  resp renderArticle(title,language,content_html)
