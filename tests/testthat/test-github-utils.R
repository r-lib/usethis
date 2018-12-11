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
