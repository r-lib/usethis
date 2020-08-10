context("use_badge")

test_that("use_[cran|bioc]_badge() don't error", {
  create_local_package()
  expect_error_free(use_cran_badge())
  expect_error_free(use_bioc_badge())
})

test_that("use_lifecycle_badge() handles bad and good input", {
  create_local_package()
  expect_error(use_lifecycle_badge(), "argument \"stage\" is missing")
  expect_error(use_lifecycle_badge("eperimental"), "'arg' should be one of ")
  expect_error_free(use_lifecycle_badge("stable"))
})

test_that("use_binder_badge() needs a github repository", {
  skip_if_no_git_user()
  create_local_project()
  use_git()
  expect_error(use_binder_badge(), class = "usethis_error_bad_github_remote_config")
})

test_that("use_badge() does nothing if badge seems to pre-exist", {
  create_local_package()
  href <- "https://cran.r-project.org/package=foo"
  writeLines(href, proj_path("README.md"))
  expect_false(use_badge("foo", href, "SRC"))
})

test_that("default readme has placeholders / can add to empty badge block", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_message(use_readme_md())
  expect_message(use_cran_badge(), "Adding CRAN status badge")
  expect_silent(use_cran_badge())
})
