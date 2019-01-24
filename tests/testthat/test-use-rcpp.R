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

test_that("use_rcpp_armadillo() creates Makevars files and edits DESCRIPTION", {
  skip_if_not_installed("RcppArmadillo")

  pkg <- scoped_temporary_package()
  use_roxygen_md()

  use_rcpp_armadillo()
  expect_match(desc::desc_get("LinkingTo", pkg), "RcppArmadillo")

  makevars_settings <- c(
    "CXX_STD = CXX11",
    "PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS)",
    "PKG_LIBS = $(SHLIB_OPENMP_CXXFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS)"
  )

  makevars <- readLines(proj_path("src", "Makevars"))
  expect_true(all(makevars_settings %in% makevars))

  makevars_win <- readLines(proj_path("src", "Makevars.win"))
  expect_true(all(makevars_settings %in% makevars_win))
})

test_that("use_rcpp_eigen() edits DESCRIPTION", {
  skip_if_not_installed("RcppEigen")

  pkg <- scoped_temporary_package()
  use_roxygen_md()

  use_rcpp_eigen()
  expect_match(desc::desc_get("LinkingTo", pkg), "RcppEigen")
  expect_match(desc::desc_get("Imports", pkg), "RcppEigen")
})

test_that("use_src() doesn't message if not needed", {
  scoped_temporary_package()
  use_roxygen_md()
  use_package_doc()
  use_src()

  withr::local_options(list(usethis.quiet = FALSE))

  expect_silent(use_src())
})
