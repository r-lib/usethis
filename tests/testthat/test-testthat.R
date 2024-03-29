test_that("use_testhat() sets up infrastructure", {
  pkg <- create_local_package()
  use_testthat()
  expect_match(proj_desc()$get("Suggests"), "testthat")
  expect_proj_dir("tests", "testthat")
  expect_proj_file("tests", "testthat.R")
  expect_true(uses_testthat())
})
