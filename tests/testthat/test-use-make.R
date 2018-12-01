context("use_makefile")

test_that("use_make() creates a Makefile at project root", {
  pkg <- scoped_temporary_package()
  use_make()
  expect_proj_file("Makefile")
})
