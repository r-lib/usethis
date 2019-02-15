context("use_lintr")

test_that("use_lintr('local') creates build-ignored, promised file", {
  scoped_temporary_package()
  use_lintr("local")
  expect_true(is_build_ignored("^\\.lintr$"))
  expect_proj_file(".lintr")
})

test_that("use_lintr('travis') creates build-ignored, promised file", {
  scoped_temporary_package()
  use_lintr("travis")
  expect_true(is_build_ignored("^\\.lintr$"))
  expect_proj_file(".lintr")
})

test_that("use_lintr('test') creates build-ignored, promised files", {
  scoped_temporary_package()
  use_lintr("test")
  expect_true(is_build_ignored("^\\.lintr$"))
  expect_true(is_build_ignored("^inst/\\.lintr$"))
  expect_proj_file("inst/.lintr")
  expect_proj_file(".lintr")
})
