context("use_code_of_conduct")

test_that("use_code_of_conduct() creates promised file", {
  scoped_temporary_project()
  capture_output(use_code_of_conduct())
  expect_true(file.exists(proj_path("CODE_OF_CONDUCT.md")))
})
