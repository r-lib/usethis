context("use_testthat")

test_that("use_testhat() sets up infrastructure", {
  pkg <- scoped_temporary_package()
  capture_output(use_testthat())
  expect_match(desc::desc_get("Suggests", proj_get()), "testthat")
  expect_true(is_dir(file.path(proj_get(), "tests/testthat")))
  expect_true(file.exists(file.path(proj_get(), "tests/testthat.R")))
  expect_true(uses_testthat())
})

test_that("use_test() creates a test file", {
  pkg <- scoped_temporary_package()
  capture_output(use_test("foo", open = FALSE))
  expect_true(file.exists(file.path(proj_get(), "tests/testthat/test-foo.R")))
})
