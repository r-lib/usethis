context("projects")

test_that("is_package() detects package-hood", {
  scoped_temporary_package()
  expect_true(is_package())

  scoped_temporary_project()
  expect_false(is_package())
})

test_that("check_is_package() errors for non-package", {
  scoped_temporary_project()
  expect_error(check_is_package(), "not an R package")
})

test_that("check_is_package() can reveal who's asking", {
  scoped_temporary_project()
  expect_error(check_is_package("foo"), "foo")
})
