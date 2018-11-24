context("use_makefile")

test_that("use_makefile() creates a Makefile at project root", {
  pkg <- scoped_temporary_package()
  use_makefile()
  expect_proj_file("Makefile")
})
