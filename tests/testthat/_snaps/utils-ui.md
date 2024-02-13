# ui_bullets() look as expected

    Code
      ui_bullets(c(`_` = "todo", v = "done", x = "oops", i = "info", "noindent", ` ` = "indent",
        `*` = "bullet", `>` = "arrow", `!` = "warning"))
    Message
      [ ] todo
      v done
      x oops
      i info
      noindent
        indent
      * bullet
      > arrow
      ! warning

# ui_bullets() respect usethis.quiet = TRUE

    Code
      ui_bullets(c(`_` = "todo", v = "done", x = "oops", i = "info", "noindent", ` ` = "indent",
        `*` = "bullet", `>` = "arrow", `!` = "warning"))

# ui_bullets() does glue interpolation and inline markup

    Code
      ui_bullets(c(i = "Hello, {x}!", v = "Updated the {.field BugReports} field", x = "Scary {.code code} or {.fun function}"))
    Message
      i Hello, world!
      v Updated the BugReports field
      x Scary `code` or `function()`

