test_that("basic legacy UI actions behave as expected", {
  # suppress test silencing
  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot({
    ui_line("line")
    ui_todo("to do")
    ui_done("done")
    ui_oops("oops")
    ui_info("info")
    ui_code_block(c("x <- 1", "y <- 2"))
    ui_warn("a warning")
  })
})

test_that("legacy UI actions respect usethis.quiet = TRUE", {
  withr::local_options(list(usethis.quiet = TRUE))

  expect_snapshot({
    ui_line("line")
    ui_todo("to do")
    ui_done("done")
    ui_oops("oops")
    ui_info("info")
    ui_code_block(c("x <- 1", "y <- 2"))
  })
})

test_that("ui_stop() works", {
  expect_usethis_error(ui_stop("an error"), "an error")
})

test_that("ui_silence() suppresses output", {
  # suppress test silencing
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(ui_silence(ui_line()), NA)
})
