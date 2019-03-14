context("test-github-utils")

test_that("parse_github_remotes() works on named list or named character", {
  urls <- list(
    https   = "https://github.com/r-lib/devtools.git",
    browser = "https://github.com/r-lib/devtools",
    ssh     = "git@github.com:r-lib/devtools.git"
  )
  expected <- list(owner = "r-lib", repo = "devtools")
  expect_identical(
    parse_github_remotes(urls),
    list(https = expected, browser = expected, ssh = expected)
  )
  expect_identical(
    parse_github_remotes(unlist(urls)),
    list(https = expected, browser = expected, ssh = expected)
  )
})

test_that("github_token() works", {
  withr::with_envvar(
    new = c("GITHUB_PAT" = "yes", "GITHUB_TOKEN" = "no"),
    expect_identical(github_token(), "yes")
  )
  withr::with_envvar(
    new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = "yes"),
    expect_identical(github_token(), "yes")
  )
  withr::with_envvar(
    new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = NA),
    expect_identical(github_token(), "")
  )
})

test_that("github_user() returns NULL if no auth_token", {
  withr::with_envvar(
    new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = NA),
    expect_null(github_user())
  )
})

test_that("github_user() returns NULL for bad token", {
  skip_if_offline()
  skip_on_cran()
  withr::with_envvar(
    new = c("GITHUB_PAT" = "abc"),
    expect_null(github_user())
  )
})
