import std/[json, options,htmlparser,xmltree]

import mummy, mummy/routers
import mummy_utils
import marvdown
import nimja/parser

import tiny_sqlite

import ../utilities/db_utils

import ../utilities/markdown_utils

var language = ""

proc renderArticlesPage(title:string = "title needed",language:string = "pt-br"): string =
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
