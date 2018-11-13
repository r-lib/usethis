context("use_badge")

test_that("use_[cran|bioc]_badge() don't error", {
  pkg <- scoped_temporary_package()
  expect_error_free(use_cran_badge())
  expect_error_free(use_bioc_badge())
})

test_that("use_lifecycle_badge() handles bad and good input", {
  pkg <- scoped_temporary_package()
  expect_error(use_lifecycle_badge(), "argument \"stage\" is missing")
  expect_error(use_lifecycle_badge("eperimental"), "'arg' should be one of ")
  expect_error_free(use_lifecycle_badge("stable"))
})

test_that("use_binder_badge() the github repository works", {
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  scoped_temporary_project()
  expect_error_free(use_binder_badge())
})

test_that("use_badge() does nothing if badge seems to pre-exist", {
  pkg <- scoped_temporary_package()
  href <- "https://cran.r-project.org/package=foo"
  writeLines(href, proj_path("README.md"))
  expect_false(use_badge("foo", href, "SRC"))
})
