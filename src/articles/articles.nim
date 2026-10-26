import std/[json, options]

import mummy, mummy/routers
import mummy_utils
import marvdown
import nimja/parser

var language = ""

proc renderArticlesPage(title:string = "title needed",language:string = "pt-br"): string =
  compileTemplateFile("articles/index.nimja",baseDir = getScriptDir() / "../templates")

proc showArticlesPage*(request: Request) =
  resp renderArticlesPage()
