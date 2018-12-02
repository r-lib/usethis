context("test-git-utils")

test_that("git_config returns old local values", {
  scoped_temporary_package()
  repo <- git_init()

  out <- git_config(x.y = "x", .repo = repo)
  expect_equal(out, list(x.y = NULL))

  out <- git_config(x.y = "y", .repo = repo)
  expect_equal(out, list(x.y = "x"))
})

test_that("git_config returns old global values", {
  out <- git_config(pkgdown.test = "x")
  expect_equal(out, list(pkgdown.test = NULL))

  out <- git_config(pkgdown.test = NULL)
  expect_equal(out, list(pkgdown.test = "x"))
})
