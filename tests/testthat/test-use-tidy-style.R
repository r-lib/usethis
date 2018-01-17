context("use_tidy_style")

test_that("styling the package works", {
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  pkg <- scoped_temporary_package()
  capture_output(use_r("bad_style"))
  path_to_bad_style <- proj_path("R/bad_style.R")
  write_utf8(path_to_bad_style, "a++2\n")
  capture_output(use_tidy_style())
  expect_identical(readLines(path_to_bad_style), "a + +2")
  unlink(path_to_bad_style)
})


test_that("styling of non-packages works", {
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  proj <- scoped_temporary_project()
  path_to_bad_style <- proj_path("R/bad_style.R")
  capture_output(use_r("bad_style"))
  write_utf8(path_to_bad_style, "a++22\n")
  capture_output(use_tidy_style())
  expect_identical(readLines(path_to_bad_style), "a + +22")
  unlink(path_to_bad_style)
})
