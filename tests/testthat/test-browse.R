test_that("github_url() errors if no project", {
  withr::local_dir(path_temp())
  local_project(NULL, force = TRUE, setwd = TRUE)
  expect_usethis_error(github_url(), "not.*inside a valid project")
})

test_that("github_url() works on active project", {
  create_local_project()
  local_interactive(FALSE)
  use_git()

  expect_usethis_error(github_url(), "no DESCRIPTION")
  expect_usethis_error(github_url(), "no GitHub remotes")

  use_description()
  use_description_field("URL", "https://example.com")
  expect_usethis_error(github_url(), "no GitHub remotes")

  issues <- "https://github.com/OWNER/REPO_BUGREPORTS/issues"
  use_description_field("BugReports", issues)
  expect_equal(github_url(), "https://github.com/OWNER/REPO_BUGREPORTS")

  origin <- "https://github.com/OWNER/REPO_ORIGIN"
  use_git_remote("origin", origin)

  expect_equal(github_url(), "https://github.com/OWNER/REPO_ORIGIN")
})

test_that("github_url() strips everything after USER/REPO", {
  expect_equal(github_url("usethis"), "https://github.com/r-lib/usethis")
  expect_equal(github_url("gh"), "https://github.com/r-lib/gh")
})

test_that("github_url() has fall back for CRAN packages", {
  expect_warning(out <- github_url("utils"), "CRAN mirror")
  expect_equal(out, "https://github.com/cran/utils")
})

test_that("github_url() errors for nonexistent package", {
  expect_usethis_error(github_url("1234"), "Can't find")
})

test_that("cran_home() produces canonical URL", {
  pkg <- create_local_package(file_temp("abc"))
  expect_match(cran_home(), "https://cran.r-project.org/package=abc")
  expect_match(cran_home("bar"), "https://cran.r-project.org/package=bar")
})

test_that("desc_urls() returns NULL if no project", {
  withr::local_dir(path_temp())
  local_project(NULL, force = TRUE, setwd = TRUE)
  expect_null(desc_urls())
})

test_that("desc_urls() returns NULL if no DESCRIPTION", {
  create_local_project()
  expect_null(desc_urls())
})

test_that("desc_urls() returns empty data frame if no URLs", {
  create_local_project()
  use_description()
  expect_equal(
    desc_urls(),
    data.frame(
      url = character(), desc_field = character(), is_github = logical(),
      stringsAsFactors = FALSE
    )
  )
})

test_that("desc_urls() returns data frame for locally installed package", {
  out <- desc_urls("curl")
  expect_true(nrow(out) > 1)
})

test_that("desc_urls() returns data frame for an uninstalled package", {
  skip_on_cran()
  skip_if_offline()

  pkg <- "devoid"
  if (requireNamespace(pkg, quietly = TRUE)) {
    skip(paste0(pkg, " is installed locally"))
  }

  out <- desc_urls(pkg)
  expect_true(nrow(out) > 1)
})

test_that("desc_urls() returns NULL for an nonexistent package", {
  skip_on_cran()
  skip_if_offline()

  expect_null(desc_urls("1234"))
})

test_that("browse_XXX() goes to correct URL", {
  local_interactive(FALSE)
  g <- function(x) paste0("https://github.com/", x)

  expect_equal(browse_github("gh"), g("r-lib/gh"))

  expect_match(browse_github_issues("gh"), g("r-lib/gh/issues"))
  expect_equal(browse_github_issues("gh", 1), g("r-lib/gh/issues/1"))
  expect_equal(browse_github_issues("gh", "new"), g("r-lib/gh/issues/new"))

  expect_match(browse_github_pulls("gh"), g("r-lib/gh/pulls"))
  expect_equal(browse_github_pulls("gh", 1), g("r-lib/gh/pull/1"))

  expect_match(browse_github_actions("gh"), g("r-lib/gh/actions"))

  expect_equal(browse_travis("usethis"), "https://travis-ci.com/r-lib/usethis")
  expect_equal(browse_travis("usethis", ext = "org"), "https://travis-ci.org/r-lib/usethis")

  expect_equal(browse_cran("usethis"), "https://cran.r-project.org/package=usethis")
})

test_that("browse_package() errors if no project", {
  withr::local_dir(path_temp())
  local_project(NULL, force = TRUE, setwd = TRUE)
  expect_usethis_error(browse_project(), "not.*inside a valid project")
})

test_that("browse_package() returns URLs", {
  create_local_project()
  use_git()

  expect_equal(browse_package(), character())

  origin <- "https://github.com/OWNER/REPO"
  use_git_remote("origin", origin)
  foofy <- "https://github.com/SOMEONE_ELSE/REPO"
  use_git_remote("foofy", foofy)

  use_description()
  pkgdown <- "https://example.com"
  use_description_field("URL", pkgdown)
  issues <- "https://github.com/OWNER/REPO/issues"
  use_description_field("BugReports", issues)

  out <- browse_package()
  expect_setequal(out, c(origin, foofy, pkgdown, issues))
})

