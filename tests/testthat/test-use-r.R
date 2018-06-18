context("use_r")

test_that("use_r() creates a .R file below R/", {
  pkg <- scoped_temporary_package()
  capture_output(use_r("foo"))
  expect_true(file_exists(proj_path("R/foo.R")))
})
