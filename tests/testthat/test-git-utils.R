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
  out <- git_config(usethis.test1 = "val1", usethis.test2 = "val2")
  expect_equal(out, list(usethis.test1 = NULL, usethis.test2 = NULL))

  out <- git_config(usethis.test1 = NULL, usethis.test2 = NULL)
  expect_equal(out, list(usethis.test1 = "val1", usethis.test2 = "val2"))
})

test_that("git_protocol() catches bad input from usethis.protocol option", {
  withr::with_options(
    list(usethis.protocol = "nope"), {
      expect_usethis_error(git_protocol(), "must be one of")
      expect_null(getOption("usethis.protocol"))
    }
  )
  withr::with_options(
    list(usethis.protocol = c("ssh", "https")), {
      expect_usethis_error(git_protocol(), "must be one of")
      expect_null(getOption("usethis.protocol"))
    }
  )
})

test_that("use_git_protocol() errors for bad input", {
  expect_usethis_error(use_git_protocol("nope"), "must be one of")
})

test_that("git_protocol() defaults to 'ssh' in a non-interactive session", {
  withr::with_options(
    list(usethis.protocol = NULL),
    expect_identical(git_protocol(), "ssh")
  )
})

test_that("non-interactive use_git_protocol(NA) is like dismissing the menu", {
  expect_usethis_error(use_git_protocol(NA), "must be either")
})

test_that("git_protocol() honors, vets, and lowercases the option", {
  withr::with_options(
    list(usethis.protocol = "ssh"),
    expect_identical(git_protocol(), "ssh")
  )
  withr::with_options(
    list(usethis.protocol = "SSH"),
    expect_identical(git_protocol(), "ssh")
  )
  withr::with_options(
    list(usethis.protocol = "https"),
    expect_identical(git_protocol(), "https")
  )
  withr::with_options(
    list(usethis.protocol = "nope"),
    expect_usethis_error(git_protocol(), "must be one of")
  )
})

test_that("use_git_protocol() prioritizes and lowercases direct input", {
  withr::with_options(
    list(usethis.protocol = "ssh"), {
      expect_identical(use_git_protocol("HTTPS"), "https")
      expect_identical(git_protocol(), "https")
    }
  )
})
