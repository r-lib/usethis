# ui_bullets() look as expected [plain]

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

# ui_bullets() look as expected [ansi]

    Code
      ui_bullets(c(`_` = "todo", v = "done", x = "oops", i = "info", "noindent", ` ` = "indent",
        `*` = "bullet", `>` = "arrow", `!` = "warning"))
    Message
      [31m[ ][39m todo
      [32mv[39m done
      [31mx[39m oops
      [33mi[39m info
      noindent
        indent
      [36m*[39m bullet
      > arrow
      [33m![39m warning

# ui_bullets() look as expected [unicode]

    Code
      ui_bullets(c(`_` = "todo", v = "done", x = "oops", i = "info", "noindent", ` ` = "indent",
        `*` = "bullet", `>` = "arrow", `!` = "warning"))
    Message
      ☐ todo
      ✔ done
      ✖ oops
      ℹ info
      noindent
        indent
      • bullet
      → arrow
      ! warning

# ui_bullets() look as expected [fancy]

    Code
      ui_bullets(c(`_` = "todo", v = "done", x = "oops", i = "info", "noindent", ` ` = "indent",
        `*` = "bullet", `>` = "arrow", `!` = "warning"))
    Message
      [31m☐[39m todo
      [32m✔[39m done
      [31m✖[39m oops
      [33mℹ[39m info
      noindent
        indent
      [36m•[39m bullet
      → arrow
      [33m![39m warning

# ui_bullets() does glue interpolation and inline markup [plain]

    Code
      ui_bullets(c(i = "Hello, {x}!", v = "Updated the {.field BugReports} field", x = "Scary {.code code} or {.fun function}"))
    Message
      i Hello, world!
      v Updated the BugReports field
      x Scary `code` or `function()`

# ui_bullets() does glue interpolation and inline markup [ansi]

    Code
      ui_bullets(c(i = "Hello, {x}!", v = "Updated the {.field BugReports} field", x = "Scary {.code code} or {.fun function}"))
    Message
      [33mi[39m Hello, world!
      [32mv[39m Updated the [32mBugReports[39m field
      [31mx[39m Scary `code` or `function()`

# ui_bullets() does glue interpolation and inline markup [unicode]

    Code
      ui_bullets(c(i = "Hello, {x}!", v = "Updated the {.field BugReports} field", x = "Scary {.code code} or {.fun function}"))
    Message
      ℹ Hello, world!
      ✔ Updated the BugReports field
      ✖ Scary `code` or `function()`

# ui_bullets() does glue interpolation and inline markup [fancy]

    Code
      ui_bullets(c(i = "Hello, {x}!", v = "Updated the {.field BugReports} field", x = "Scary {.code code} or {.fun function}"))
    Message
      [33mℹ[39m Hello, world!
      [32m✔[39m Updated the [32mBugReports[39m field
      [31m✖[39m Scary `code` or `function()`

