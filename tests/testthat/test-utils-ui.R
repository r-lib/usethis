cli::test_that_cli("ui_bullets() look as expected", {
  # suppress test silencing
  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot(
    ui_bullets(c(
      # relate to legacy functions
      "_" = "todo", # ui_todo()
      "v" = "done", # ui_done()
      "x" = "oops", # ui_oops()
      "i" = "info", # ui_info()
            "noindent", # ui_line()

      # other cli bullets that have no special connection to usethis history
      " " = "indent",
      "*" = "bullet",
      ">" = "arrow",
      "!" = "warning"
    ))
  )
})

test_that("ui_bullets() respect usethis.quiet = TRUE", {
  withr::local_options(list(usethis.quiet = TRUE))

  expect_no_message(
    ui_bullets(c(
      # relate to legacy functions
      "_" = "todo", # ui_todo()
      "v" = "done", # ui_done()
      "x" = "oops", # ui_oops()
      "i" = "info", # ui_info()
            "noindent", # ui_line()

      # other cli bullets that have no special connection to usethis history
      " " = "indent",
      "*" = "bullet",
      ">" = "arrow",
      "!" = "warning"
    ))
  )
})

cli::test_that_cli("ui_bullets() does glue interpolation and inline markup", {
  # suppress test silencing
  withr::local_options(list(usethis.quiet = FALSE))

  x <- "world"

  expect_snapshot(
    ui_bullets(c(
      "i" = "Hello, {x}!",
      "v" = "Updated the {.field BugReports} field",
      "x" = "Scary {.code code} or {.fun function}"
    ))
  )
})

test_that("trailing slash behaviour of ui_path_impl()", {
  # target doesn't exist so no empirical evidence that it's a directory
  expect_match(ui_path_impl("abc"), "abc$")

  # path suggests it's a directory
  expect_match(ui_path_impl("abc/"), "abc/$")
  expect_match(ui_path_impl("abc//"), "abc/$")

  # path is known to be a directory
  tmpdir <- withr::local_tempdir(pattern = "ui_path_impl")

  expect_match(ui_path_impl(tmpdir), "/$")
  expect_match(ui_path_impl(paste0(tmpdir, "/")), "[^/]/$")
  expect_match(ui_path_impl(paste0(tmpdir, "//")), "[^/]/$")
})

test_that("ui_abort() works", {
  expect_usethis_error(ui_abort("spatula"), "spatula")

  # usethis.quiet should have no effect on this
  withr::local_options(list(usethis.quiet = TRUE))
  expect_usethis_error(ui_abort("whisk"), "whisk")

})

cli::test_that_cli("ui_code_snippet() with scalar input", {
  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot(
    ui_code_snippet("
      options(
        warnPartialMatchArgs = TRUE,
        warnPartialMatchDollar = TRUE,
        warnPartialMatchAttr = TRUE
      )")
  )
}, configs = c("plain", "ansi"))

cli::test_that_cli("ui_code_snippet() with vector input", {
  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot(
    ui_code_snippet(c(
      "options(",
      "  warnPartialMatchArgs = TRUE,",
      "  warnPartialMatchDollar = TRUE,",
      "  warnPartialMatchAttr = TRUE",
      ")"
    ))
  )
}, configs = c("plain", "ansi"))

cli::test_that_cli("ui_code_snippet() when language is not R", {
  withr::local_options(list(usethis.quiet = FALSE))
  h <- "blah.h"
  expect_snapshot(
    ui_code_snippet("#include <{h}>", language = "")
  )
}, configs = c("plain", "ansi"))

cli::test_that_cli("ui_code_snippet() can interpolate", {
  withr::local_options(list(usethis.quiet = FALSE))

  true_val <- "TRUE"
  false_val <- "'FALSE'"

  expect_snapshot(
    ui_code_snippet("if (1) {true_val} else {false_val}")
  )
}, configs = c("plain", "ansi"))

cli::test_that_cli("ui_code_snippet() can NOT interpolate", {
  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot({
    ui_code_snippet(
      "foo <- function(x){x}",
      interpolate = FALSE
    )
    ui_code_snippet(
      "foo <- function(x){{x}}",
      interpolate = TRUE
    )
  })
}, configs = c("plain", "ansi"))

test_that("bulletize() works", {
  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot(ui_bullets(bulletize(letters)))
  expect_snapshot(ui_bullets(bulletize(letters, bullet = "x")))
  expect_snapshot(ui_bullets(bulletize(letters, n_show = 2)))
  expect_snapshot(ui_bullets(bulletize(letters[1:6])))
  expect_snapshot(ui_bullets(bulletize(letters[1:7])))
  expect_snapshot(ui_bullets(bulletize(letters[1:8])))
  expect_snapshot(ui_bullets(bulletize(letters[1:6], n_fudge = 0)))
  expect_snapshot(ui_bullets(bulletize(letters[1:8], n_fudge = 3)))
})

test_that("usethis_map_cli() works", {
  x <- c("aaa", "bbb", "ccc")
  expect_equal(
    usethis_map_cli(x, template = "{.file <<x>>}"),
    c("{.file aaa}", "{.file bbb}", "{.file ccc}")
  )
})
