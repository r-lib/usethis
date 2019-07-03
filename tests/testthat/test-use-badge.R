context("use_badge")

test_that("use_[cran|bioc]_badge() don't error", {
  scoped_temporary_package()
  expect_error_free(use_cran_badge())
  expect_error_free(use_bioc_badge())
})

test_that("use_lifecycle_badge() handles bad and good input", {
  scoped_temporary_package()
  expect_error(use_lifecycle_badge(), "argument \"stage\" is missing")
  expect_error(use_lifecycle_badge("eperimental"), "'arg' should be one of ")
  expect_error_free(use_lifecycle_badge("stable"))
})

test_that("use_binder_badge() needs a github repository", {
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  scoped_temporary_project()
  expect_error(use_binder_badge())
})

test_that("use_badge() does nothing if badge seems to pre-exist", {
  scoped_temporary_package()
  href <- "https://cran.r-project.org/package=foo"
  writeLines(href, proj_path("README.md"))
  expect_false(use_badge("foo", href, "SRC"))
})

test_that("default readme has placeholders / can add to empty badge block", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(use_readme_md())
  expect_output(use_cran_badge(), "Adding CRAN status badge")
  expect_silent(use_cran_badge())
})
