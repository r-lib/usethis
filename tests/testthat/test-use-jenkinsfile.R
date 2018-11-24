context("use_jenkinsfile")

test_that("use_makefile() creates a Makefile AND a Jenkinsfile at project root", {
  pkg <- scoped_temporary_package()
  use_jenkinsfile()
  expect_proj_file("Makefile")
  expect_proj_file("Jenkinsfile")
})
