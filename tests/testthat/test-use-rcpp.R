context("use-rcpp.R")

test_that("use_rcpp() requires a package", {
  scoped_temporary_project()
  expect_error(use_rcpp(), "not an R package")
})

test_that("use_rcpp() creates files/dirs, edits DESCRIPTION and .gitignore", {
  pkg <- scoped_temporary_package()
  use_roxygen_md()

  use_rcpp()
  expect_match(desc::desc_get("LinkingTo", pkg), "Rcpp")
  expect_match(desc::desc_get("Imports", pkg), "Rcpp")
  expect_proj_dir("src")

  ignores <- readLines(proj_path("src", ".gitignore"))
  expect_true(all(c("*.o", "*.so", "*.dll") %in% ignores))
})

test_that("use_src() doesn't message if not needed", {
  withr::local_options(list(usethis.quiet = FALSE))
  scoped_temporary_package()
  expect_output(use_roxygen_md())
  expect_output(use_package_doc())

  expect_output(use_src())
  expect_output(use_src(), NA)
})
