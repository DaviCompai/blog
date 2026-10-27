import marvdown

proc markdownToHtml*(md_input: string): string {.gcsafe.}=
  let opts = MarkdownOptions(
    allowed: @[]
  )

  var html: string
  {.cast(gcsafe).}:
    var md = newMarkdown(md_input, opts)
    html = md.toHtml

  html
