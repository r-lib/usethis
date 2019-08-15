context("use_package")

test_that("use_package() won't facilitate dependency on tidyverse", {
  scoped_temporary_package()
  expect_usethis_error(use_package("tidyverse"), "rarely a good idea")
})
