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
      v Updated the 'BugReports' field
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
      ✔ Updated the 'BugReports' field
      ✖ Scary `code` or `function()`

# ui_bullets() does glue interpolation and inline markup [fancy]

    Code
      ui_bullets(c(i = "Hello, {x}!", v = "Updated the {.field BugReports} field", x = "Scary {.code code} or {.fun function}"))
    Message
      [33mℹ[39m Hello, world!
      [32m✔[39m Updated the [32mBugReports[39m field
      [31m✖[39m Scary `code` or `function()`

# ui_code_snippet() with scalar input [plain]

    Code
      ui_code_snippet(
        "\n      options(\n        warnPartialMatchArgs = TRUE,\n        warnPartialMatchDollar = TRUE,\n        warnPartialMatchAttr = TRUE\n      )")
    Message
        options(
          warnPartialMatchArgs = TRUE,
          warnPartialMatchDollar = TRUE,
          warnPartialMatchAttr = TRUE
        )

# ui_code_snippet() with scalar input [ansi]

    Code
      ui_code_snippet(
        "\n      options(\n        warnPartialMatchArgs = TRUE,\n        warnPartialMatchDollar = TRUE,\n        warnPartialMatchAttr = TRUE\n      )")
    Message
        [36moptions[39m[33m([39m
          warnPartialMatchArgs = [34mTRUE[39m,
          warnPartialMatchDollar = [34mTRUE[39m,
          warnPartialMatchAttr = [34mTRUE[39m
        [33m)[39m

# ui_code_snippet() with vector input [plain]

    Code
      ui_code_snippet(c("options(", "  warnPartialMatchArgs = TRUE,",
        "  warnPartialMatchDollar = TRUE,", "  warnPartialMatchAttr = TRUE", ")"))
    Message
        options(
          warnPartialMatchArgs = TRUE,
          warnPartialMatchDollar = TRUE,
          warnPartialMatchAttr = TRUE
        )

# ui_code_snippet() with vector input [ansi]

    Code
      ui_code_snippet(c("options(", "  warnPartialMatchArgs = TRUE,",
        "  warnPartialMatchDollar = TRUE,", "  warnPartialMatchAttr = TRUE", ")"))
    Message
        [36moptions[39m[33m([39m
          warnPartialMatchArgs = [34mTRUE[39m,
          warnPartialMatchDollar = [34mTRUE[39m,
          warnPartialMatchAttr = [34mTRUE[39m
        [33m)[39m

# ui_code_snippet() when language is not R [plain]

    Code
      ui_code_snippet("#include <{h}>", language = "")
    Message
        #include <blah.h>

# ui_code_snippet() when language is not R [ansi]

    Code
      ui_code_snippet("#include <{h}>", language = "")
    Message
        #include <blah.h>

# ui_code_snippet() can interpolate [plain]

    Code
      ui_code_snippet("if (1) {true_val} else {false_val}")
    Message
        if (1) TRUE else 'FALSE'

# ui_code_snippet() can interpolate [ansi]

    Code
      ui_code_snippet("if (1) {true_val} else {false_val}")
    Message
        [31mif[39m [33m([39m[34m1[39m[33m)[39m [34mTRUE[39m [31melse[39m [33m'FALSE'[39m

# ui_code_snippet() can NOT interpolate [plain]

    Code
      ui_code_snippet("foo <- function(x){x}", interpolate = FALSE)
    Message
        foo <- function(x){x}
    Code
      ui_code_snippet("foo <- function(x){{x}}", interpolate = TRUE)
    Message
        foo <- function(x){x}

# ui_code_snippet() can NOT interpolate [ansi]

    Code
      ui_code_snippet("foo <- function(x){x}", interpolate = FALSE)
    Message
        foo [32m<-[39m [31mfunction[39m[33m([39mx[33m)[39m[33m{[39mx[33m}[39m
    Code
      ui_code_snippet("foo <- function(x){{x}}", interpolate = TRUE)
    Message
        foo [32m<-[39m [31mfunction[39m[33m([39mx[33m)[39m[33m{[39mx[33m}[39m

# bulletize() works

    Code
      ui_bullets(bulletize(letters))
    Message
      * a
      * b
      * c
      * d
      * e
        ... and 21 more

---

    Code
      ui_bullets(bulletize(letters, bullet = "x"))
    Message
      x a
      x b
      x c
      x d
      x e
        ... and 21 more

---

    Code
      ui_bullets(bulletize(letters, n_show = 2))
    Message
      * a
      * b
        ... and 24 more

---

    Code
      ui_bullets(bulletize(letters[1:6]))
    Message
      * a
      * b
      * c
      * d
      * e
      * f

---

    Code
      ui_bullets(bulletize(letters[1:7]))
    Message
      * a
      * b
      * c
      * d
      * e
      * f
      * g

---

    Code
      ui_bullets(bulletize(letters[1:8]))
    Message
      * a
      * b
      * c
      * d
      * e
        ... and 3 more

---

    Code
      ui_bullets(bulletize(letters[1:6], n_fudge = 0))
    Message
      * a
      * b
      * c
      * d
      * e
        ... and 1 more

---

    Code
      ui_bullets(bulletize(letters[1:8], n_fudge = 3))
    Message
      * a
      * b
      * c
      * d
      * e
      * f
      * g
      * h

