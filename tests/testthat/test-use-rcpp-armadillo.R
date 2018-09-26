context("use-rcpp-armadillo.R")

test_that("use_rcpp_armadillo() requires a package", {
  scoped_temporary_project()
  expect_error(use_rcpp_armadillo(), "not an R package")
})

test_that("use_rcpp_armadillo() edits DESCRIPTION", {
  pkg <- scoped_temporary_package()
  use_rcpp_armadillo()
  expect_match(desc::desc_get("LinkingTo", pkg), "Rcpp")
  expect_match(desc::desc_get("LinkingTo", pkg), "RcppArmadillo")
  expect_match(desc::desc_get("Imports", pkg), "Rcpp")
})

test_that("use_rcpp_armadillo() creates src/, edits Makevars and .gitignore", {
  pkg <- scoped_temporary_package()
  use_rcpp_armadillo()
  expect_proj_dir("src")
  ignores <- readLines(proj_path("src", ".gitignore"))
  expect_true(all(c("*.o", "*.so", "*.dll") %in% ignores))
  cxx_std <- "CXX_STD = CXX11"
  cxx_flags <- "PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS)"
  pkg_libs <- paste("PKG_LIBS = $(SHLIB_OPENMP_CXXFLAGS) $(LAPACK_LIBS)",
                    "$(BLAS_LIBS) $(FLIBS)")
  makevars_settings <- c(cxx_std, cxx_flags, pkg_libs)
  makevars <- readLines(proj_path("src", "Makevars"))
  expect_true(all(makevars_settings %in% makevars))
  makevars_win <- readLines(proj_path("src", "Makevars"))
  expect_true(all(makevars_settings %in% makevars_win))
})
