test_that("use_rcpp() requires a package", {
  create_local_project()
  expect_usethis_error(use_rcpp(), "not an R package")
})

test_that("use_rcpp() creates files/dirs, edits DESCRIPTION and .gitignore", {
  pkg <- create_local_package()
  use_roxygen_md()

  use_rcpp()
  expect_match(desc::desc_get("LinkingTo", pkg), "Rcpp")
  expect_match(desc::desc_get("Imports", pkg), "Rcpp")
  expect_proj_dir("src")

  ignores <- read_utf8(proj_path("src", ".gitignore"))
  expect_true(all(c("*.o", "*.so", "*.dll") %in% ignores))
})

test_that("use_rcpp_armadillo() creates Makevars files and edits DESCRIPTION", {
  create_local_package()
  use_roxygen_md()

  local_interactive(FALSE)
  with_mock(
    # Required to pass the check re: whether RcppArmadillo is installed
    check_installed = function(pkg) TRUE,
    use_rcpp_armadillo()
  )
  expect_match(desc::desc_get("LinkingTo"), "RcppArmadillo")
  expect_proj_file("src", "Makevars")
  expect_proj_file("src", "Makevars.win")
})

test_that("use_rcpp_eigen() edits DESCRIPTION", {
  create_local_package()
  use_roxygen_md()

  with_mock(
    # Required to pass the check re: whether RcppEigen is installed
    check_installed = function(pkg) TRUE,
    use_rcpp_eigen()
  )
  expect_match(desc::desc_get("LinkingTo"), "RcppEigen")
})

test_that("use_src() doesn't message if not needed", {
  create_local_package()
  use_roxygen_md()
  use_package_doc()
  use_src()

  withr::local_options(list(usethis.quiet = FALSE))

  expect_silent(use_src())
})

test_that("use_makevars() respects pre-existing Makevars", {
  pkg <- create_local_package()

  dir_create(proj_path("src"))
  makevars_file <- proj_path("src", "Makevars")
  makevars_win_file <- proj_path("src", "Makevars.win")

  writeLines("USE_CXX = CXX11", makevars_file)
  file_copy(makevars_file, makevars_win_file)

  before_makevars_file <- read_utf8(makevars_file)
  before_makevars_win_file <- read_utf8(makevars_win_file)

  makevars_settings <- list(
    "PKG_CXXFLAGS" = "-Wno-reorder"
  )
  use_makevars(makevars_settings)

  expect_identical(before_makevars_file, read_utf8(makevars_file))
  expect_identical(before_makevars_win_file, read_utf8(makevars_win_file))
})

test_that("use_makevars() creates Makevars files with appropriate configuration", {
  pkg <- create_local_package()

  makevars_settings <- list(
    "CXX_STD" = "CXX11"
  )
  use_makevars(makevars_settings)

  makevars_content <- paste0(names(makevars_settings), " = ", makevars_settings)

  expect_identical(makevars_content, read_utf8(proj_path("src", "Makevars")))
  expect_identical(makevars_content, read_utf8(proj_path("src", "Makevars.win")))
})
