context("use_tidy_style")

test_that("styling the package works", {
  pkg <- scoped_temporary_package()
  use_r("bad_style")
  path_to_bad_style <- proj_path("R/bad_style.R")
  write_utf8(path_to_bad_style, "a=2\n")
  use_tidy_style()
  expect_identical(readLines(path_to_bad_style), "a <- 2")
  unlink(path_to_bad_style)
})
