context("use_package")

test_that("use_package() won't facilitate dependency on tidyverse, devtools", {
  scoped_temporary_package()
  expect_error(use_package("tidyverse"), "rarely a good idea")
  expect_error(use_package("devtools"), "rarely a good idea")
})
