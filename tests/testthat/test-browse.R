context("browse")

test_that("github_home() strips everything after USER/REPO", {
  expect_equal(github_home("usethis"), "https://github.com/r-lib/usethis")
  expect_equal(github_home("gh"), "https://github.com/r-lib/gh")
})

test_that("github_home() has fall back", {
  expect_warning(out <- github_home("utils"), "CRAN mirror")
  expect_equal(out, "https://github.com/cran/utils")
})

test_that("cran_home() produces canonical URL", {
  pkg <- create_local_package(file_temp("abc"))
  expect_match(cran_home(), "https://cran.r-project.org/package=abc")
  expect_match(cran_home("bar"), "https://cran.r-project.org/package=bar")
})

test_that("browse_XXX() goes to correct URL", {
  skip_if(rlang::is_interactive())
  g <- function(x) paste0("https://github.com/", x)

  expect_equal(browse_github("gh"), g("r-lib/gh"))

  expect_match(browse_github_issues("gh"), g("r-lib/gh/issues"))
  expect_equal(browse_github_issues("gh", 1), g("r-lib/gh/issues/1"))
  expect_equal(browse_github_issues("gh", "new"), g("r-lib/gh/issues/new"))

  expect_match(browse_github_pulls("gh"), g("r-lib/gh/pulls"))
  expect_equal(browse_github_pulls("gh", 1), g("r-lib/gh/pull/1"))

  expect_equal(browse_travis("usethis"), "https://travis-ci.com/r-lib/usethis")
  expect_equal(browse_travis("usethis", ext = "org"), "https://travis-ci.org/r-lib/usethis")

  expect_equal(browse_cran("usethis"), "https://cran.r-project.org/package=usethis")
})
