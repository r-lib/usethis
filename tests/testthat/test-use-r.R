context("use_r")

test_that("use_r() creates a .R file below R/", {
  pkg <- scoped_temporary_package()
  use_r("foo")
  expect_proj_file("R/foo.R")
})

test_that("use_r doesn't accept multiple file names", {
  pkg <- scoped_temporary_package()
  expect_error(use_r(c("file1", "file2")))
})
