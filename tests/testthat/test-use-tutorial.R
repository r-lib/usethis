context("test-use-tutorial")

test_that("use_tutorial() requires a `name`", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  expect_error(use_tutorial(), "no default")
})

test_that("use_tutorial() creates a tutorials folder", {
  scoped_temporary_package()
  use_tutorial("test-file", "test-title")
  expect_proj_dir(path("inst", "tutorials"))
})
