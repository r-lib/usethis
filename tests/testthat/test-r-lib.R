context("r-lib")

test_that("use_lifecycle() imports badges", {
  scoped_temporary_package()
  use_lifecycle()
  expect_proj_file("man", "figures", "lifecycle-stable.svg")
})
