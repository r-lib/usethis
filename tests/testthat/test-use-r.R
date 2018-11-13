context("use_r")

test_that("use_r() creates a .R file below R/", {
  pkg <- scoped_temporary_package()
  use_r("foo")
  expect_proj_file("R/foo.R")
})
