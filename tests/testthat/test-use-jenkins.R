context("use_jenkins")

test_that("use_jenkins() creates a Makefile AND a Jenkinsfile at project root", {
  pkg <- scoped_temporary_package()
  use_jenkins()
  expect_proj_file("Makefile")
  expect_proj_file("Jenkinsfile")
})
