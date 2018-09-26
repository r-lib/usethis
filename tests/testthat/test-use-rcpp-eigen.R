context("use-rcpp-eigen.R")

test_that("use_rcpp_eigen() requires a package", {
  scoped_temporary_project()
  expect_error(use_rcpp_eigen(), "not an R package")
})

test_that("use_rcpp_eigen() makes files/dirs, edits DESCRIPTION & .gitignore", {
  pkg <- scoped_temporary_package()
  use_rcpp_eigen()
  expect_match(desc::desc_get("LinkingTo", pkg), "Rcpp")
  expect_match(desc::desc_get("LinkingTo", pkg), "RcppEigen")
  expect_match(desc::desc_get("Imports", pkg), "Rcpp")
  expect_match(desc::desc_get("Imports", pkg), "RcppEigen")
  expect_proj_dir("src")
  ignores <- readLines(proj_path("src", ".gitignore"))
  expect_true(all(c("*.o", "*.so", "*.dll") %in% ignores))
})
