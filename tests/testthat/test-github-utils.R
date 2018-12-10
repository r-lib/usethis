context("test-github-utils")

test_that("parse_github_remotes() works on named character or named list", {
  urls <- c(
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
    parse_github_remotes(as.list(urls)),
    list(https = expected, browser = expected, ssh = expected)
  )
})
