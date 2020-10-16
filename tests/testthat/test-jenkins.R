test_that("use_jenkins() creates a Makefile AND a Jenkinsfile at project root", {
  pkg <- create_local_package()
  use_jenkins()
  expect_proj_file("Makefile")
  expect_proj_file("Jenkinsfile")
})
