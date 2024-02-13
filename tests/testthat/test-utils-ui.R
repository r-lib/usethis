test_that("ui_bullets() look as expected", {
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

test_that("ui_bullets() does glue interpolation and inline markup", {
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
