test_that("use_make() creates a Makefile at project root", {
  pkg <- create_local_package()
  use_make()
  expect_proj_file("Makefile")
})
