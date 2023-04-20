test_that("use_tidy_eval() is defunct", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  expect_snapshot(use_tidy_eval(), error = TRUE)
})

