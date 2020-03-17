test_that("use_r() creates a .R file below R/", {
  pkg <- scoped_temporary_package()
  use_r("foo")
  expect_proj_file("R/foo.R")
})

test_that("use_test() creates a test file", {
  pkg <- scoped_temporary_package()
  use_test("foo", open = FALSE)
  expect_proj_file("tests", "testthat", "test-foo.R")
})


# rename_files ------------------------------------------------------------

test_that("renames R and test files", {
  scoped_temporary_package()
  git_init()

  use_r("foo", open = FALSE)
  rename_files("foo", "bar")
  expect_proj_file("R/bar.R")

  use_test("foo", open = FALSE)
  rename_files("foo", "bar")
  expect_proj_file("tests/testthat/test-bar.R")
})


# helpers -----------------------------------------------------------------

test_that("check_file_name() requires single vector", {
  expect_usethis_error(check_file_name(c("a", "b")), "single string")
})

