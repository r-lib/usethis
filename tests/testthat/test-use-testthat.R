context("use_testthat")

test_that("use_testhat() sets up infrastructure", {
  pkg <- scoped_temporary_package()
  use_testthat()
  expect_match(desc::desc_get("Suggests", proj_get()), "testthat")
  expect_proj_dir("tests", "testthat")
  expect_proj_file("tests", "testthat.R")
  expect_true(uses_testthat())
})

test_that("use_test() creates a test file", {
  pkg <- scoped_temporary_package()
  use_test("foo", open = FALSE)
  expect_proj_file("tests", "testthat", "test-foo.R")
})
