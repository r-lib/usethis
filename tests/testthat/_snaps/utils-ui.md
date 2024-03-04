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
      * bullet
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
      • bullet
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

# ui_abort() defaults to 'x' for first bullet

    Code
      ui_abort("no explicit bullet")
    Condition
      Error:
      x no explicit bullet

# ui_abort() can take explicit first bullet

    Code
      ui_abort(c(v = "success bullet"))
    Condition
      Error:
      v success bullet

# ui_abort() defaults to 'i' for non-first bullet

    Code
      ui_abort(c("oops", ` ` = "space bullet", "info bullet", v = "success bullet"))
    Condition
      Error:
      x oops
        space bullet
      i info bullet
      v success bullet

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

# ui_special() works [plain]

    Code
      cli::cli_text(ui_special())
    Message
      <unset>

---

    Code
      cli::cli_text(ui_special("whatever"))
    Message
      <whatever>

# ui_special() works [ansi]

    Code
      cli::cli_text(ui_special())
    Message
      [90m<unset>[39m

---

    Code
      cli::cli_text(ui_special("whatever"))
    Message
      [90m<whatever>[39m

# kv_line() looks as expected in basic use [plain]

    Code
      kv_line("CHARACTER", "VALUE")
    Message
      * CHARACTER: "VALUE"
    Code
      kv_line("NUMBER", 1)
    Message
      * NUMBER: 1
    Code
      kv_line("LOGICAL", TRUE)
    Message
      * LOGICAL: TRUE

# kv_line() looks as expected in basic use [fancy]

    Code
      kv_line("CHARACTER", "VALUE")
    Message
      • CHARACTER: [34m"VALUE"[39m
    Code
      kv_line("NUMBER", 1)
    Message
      • NUMBER: [34m1[39m
    Code
      kv_line("LOGICAL", TRUE)
    Message
      • LOGICAL: [34mTRUE[39m

# kv_line() can interpolate and style inline in key [plain]

    Code
      kv_line("Let's reveal {.field {field}}", "whatever")
    Message
      * Let's reveal 'SOME_FIELD': "whatever"

# kv_line() can interpolate and style inline in key [fancy]

    Code
      kv_line("Let's reveal {.field {field}}", "whatever")
    Message
      • Let's reveal [32mSOME_FIELD[39m: [34m"whatever"[39m

# kv_line() can treat value in different ways [plain]

    Code
      kv_line("Key", value)
    Message
      * Key: "some value"
    Code
      kv_line("Something we don't have", NULL)
    Message
      * Something we don't have: <unset>
    Code
      kv_line("Key", ui_special("discovered"))
    Message
      * Key: <discovered>
    Code
      kv_line("Key", "something {.emph important}")
    Message
      * Key: "something {.emph important}"
    Code
      kv_line("Key", I("something {.emph important}"))
    Message
      * Key: something important
    Code
      kv_line("Key", I("something {.emph {adjective}}"))
    Message
      * Key: something great
    Code
      kv_line("Interesting file", I("{.url {url}}"))
    Message
      * Interesting file: <https://usethis.r-lib.org/>

# kv_line() can treat value in different ways [fancy]

    Code
      kv_line("Key", value)
    Message
      • Key: [34m"some value"[39m
    Code
      kv_line("Something we don't have", NULL)
    Message
      • Something we don't have: [90m<unset>[39m
    Code
      kv_line("Key", ui_special("discovered"))
    Message
      • Key: [90m<discovered>[39m
    Code
      kv_line("Key", "something {.emph important}")
    Message
      • Key: [34m"something {.emph important}"[39m
    Code
      kv_line("Key", I("something {.emph important}"))
    Message
      • Key: something [3mimportant[23m
    Code
      kv_line("Key", I("something {.emph {adjective}}"))
    Message
      • Key: something [3mgreat[23m
    Code
      kv_line("Interesting file", I("{.url {url}}"))
    Message
      • Interesting file: [3m[34m<https://usethis.r-lib.org/>[39m[23m

