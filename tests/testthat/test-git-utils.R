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

test_that("git_use_protocol() errors for bad input", {
  expect_error(use_git_protocol(c("ssh", "https")), "length.*not TRUE")
  expect_error(use_git_protocol("nope"), "protocol.*not TRUE")
})

test_that("git_use_protocol() defaults to 'ssh' in a non-interactive session", {
  withr::with_options(
    list(usethis.protocol = NULL),
    expect_identical(use_git_protocol(), "ssh")
  )
})

test_that("non-interactive git_use_protocol(NA) is like dismissing the menu", {
  expect_error(use_git_protocol(NA), "must be either")
})

test_that("git_use_protocol() honors, vets, and lowercases the option", {
  withr::with_options(
    list(usethis.protocol = "ssh"),
    expect_identical(use_git_protocol(), "ssh")
  )
  withr::with_options(
    list(usethis.protocol = "SSH"),
    expect_identical(use_git_protocol(), "ssh")
  )
  withr::with_options(
    list(usethis.protocol = "https"),
    expect_identical(use_git_protocol(), "https")
  )
  withr::with_options(
    list(usethis.protocol = "nope"),
    expect_error(use_git_protocol(), "should be one of")
  )
})

test_that("git_use_protocol() prioritizes and lowercases direct input", {
  withr::with_options(
    list(usethis.protocol = "ssh"),
    expect_identical(use_git_protocol("HTTPS"), "https")
  )
})
