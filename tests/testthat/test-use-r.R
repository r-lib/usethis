context("use_r")

test_that("use_r() creates a .R file below R/", {
  pkg <- scoped_temporary_package()
  use_r("foo")
  expect_proj_file("R/foo.R")
})

test_that("check_file_name() requires single vector", {
  expect_usethis_error(check_file_name(c("a", "b")), "single string")
})
