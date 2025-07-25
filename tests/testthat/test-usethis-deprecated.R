test_that("use_tidy_eval() is deprecated", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  expect_snapshot(use_tidy_eval(), error = TRUE)
})

test_that("use_tidy_style() is deprecated", {
  expect_snapshot(use_tidy_style())
})
