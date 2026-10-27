import std/[json, options]

import mummy, mummy/routers
import mummy_utils

import marvdown

import nimja/parser

import tiny_sqlite

import articles/articles

import utilities/db_utils

# proc renderArticlesPage()

proc markdownToHtmlTest(request: Request) {.gcsafe.}=
  let opts = MarkdownOptions(
    allowed: @[tagP, tagStrong, tagEm, tagA, tagCode, tagPre],
    enableAnchors: true,
    anchorIcon: "*"
  )

  var html: string
  {.cast(gcsafe).}:
    var md = newMarkdown(@"markdown", opts)
    html = md.toHtml

  resp html

proc renderIndexMarkdownToHtml(): string =
  compileTemplateFile("templates/index.nimja", baseDir = getScriptDir())

proc markdownToHtmlTestGet(request: Request) =
  resp renderIndexMarkdownToHtml()

var router: Router
router.post("/markdown",markdownToHtmlTest)
router.get("/markdown", markdownToHtmlTestGet)
router.get("/",showArticlesPage)
router.get("/create",showMakePostPage)
router.post("/create",PostArticle)
router.get("/login",showLoginPage)
router.post("/login",PostLogin)
# router.get("/redirect", indexRedirect)
# router.get("/headers", indexHeaders)
# router.head("/headers", indexHead)
# router.post("/headers", indexPost)
# router.get("/file/@filename", indexFile)
# router.post("/multipart", indexMultipart)
#

let server = newServer(router, workerThreads = 4)
echo "Serving on http://localhost:8086"
server.serve(Port(8086))
