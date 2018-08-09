context("use_tidy_style")

test_that("styling the package works", {
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  skip_if_not_installed("styler")

  pkg <- scoped_temporary_package()
  use_r("bad_style")
  path_to_bad_style <- proj_path("R/bad_style.R")
  write_utf8(path_to_bad_style, "a++2\n")
  capture_output(use_tidy_style())
  expect_identical(readLines(path_to_bad_style), "a + +2")
  file_delete(path_to_bad_style)
})


test_that("styling of non-packages works", {
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  skip_if_not_installed("styler")

  proj <- scoped_temporary_project()
  path_to_bad_style <- proj_path("R/bad_style.R")
  use_r("bad_style")
  write_utf8(path_to_bad_style, "a++22\n")
  capture_output(use_tidy_style())
  expect_identical(readLines(path_to_bad_style), "a + +22")
  file_delete(path_to_bad_style)
})
