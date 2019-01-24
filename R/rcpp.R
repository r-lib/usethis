#' Use C, C++, RcppArmadillo, or RcppEigen.
#'
#' Creates `src/`, adds required packages to `DESCRIPTION`,
#' optionally creates `.c` or `.cpp` files
#' as well as `Makevars` and `Makevars.win` files.
#'
#' @param name If supplied, creates and opens `src/name.{c,cpp}`.
#' @export
use_rcpp <- function(name = NULL) {
  check_is_package("use_rcpp()")
  check_uses_roxygen("use_rcpp()")

  use_src()

  use_dependency("Rcpp", "LinkingTo")
  use_dependency("Rcpp", "Imports")
  roxygen_ns_append("@importFrom Rcpp sourceCpp") && roxygen_update()

  if (!is.null(name)) {
    name <- slug(name, "cpp")
    check_file_name(name)

    use_template("code.cpp", path("src", name), open = TRUE)
  }

  invisible()
}

#' @rdname use_rcpp
#' @export
use_rcpp_armadillo <- function(name = NULL) {
  use_rcpp(name)

  use_dependency("RcppArmadillo", "LinkingTo")

  makevars_path <- proj_path("src/Makevars")
  makevars_win_path <- proj_path("src/Makevars.win")

  package <- "RcppArmadillo"
  set_makevars(makevars_path)
  ui_done("Adding {ui_value(package)} settings to {ui_value(makevars_path)}")
  set_makevars(makevars_win_path)
  ui_done("Adding {ui_value(package)} settings to {ui_value(makevars_win_path)}")

  invisible()
}

#' @rdname use_rcpp
#' @export
use_rcpp_eigen <- function(name = NULL) {
  use_rcpp(name)

  use_dependency("RcppEigen", "LinkingTo")
  use_dependency("RcppEigen", "Imports")

  roxygen_ns_append("@import RcppEigen") && roxygen_update()

  invisible()
}

#' @rdname use_rcpp
#' @export
use_c <- function(name = NULL) {
  use_src()

  if (!is.null(name)) {
    name <- slug(name, "c")
    check_file_name(name)

    use_template("code.c", path("src", name), open = TRUE)
  }

  invisible(TRUE)
}

use_src <- function() {
  check_is_package("use_src()")
  check_uses_roxygen("use_rcpp()")

  use_directory("src")
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src")
  roxygen_ns_append(glue("@useDynLib {project_name()}, .registration = TRUE")) &&
    roxygen_update()

  invisible()
}

set_makevars <- function(path) {
  # This will (at first) be similar to write_union() (in R/write.R),
  # but we also have to handle the case where some flags are already set,
  # so we will be appending text to the end of a line
  # (rather than always adding new lines)

  path <- user_path_prep(path)

  # If a Makevars file exists, read in its lines;
  # otherwise, make an empty character vector
  if (file_exists(path)) {
    makevars <- readLines(path, warn = FALSE, encoding = "UTF-8")
  } else {
    makevars <- character()
  }

  # These are the settings we'll ultimately want
  # (as they would be set by RcppArmadillo::RcppArmadillo.package.skeleton):
  settings <- c("CXX11", "$(SHLIB_OPENMP_CXXFLAGS)",
                "$(SHLIB_OPENMP_CXXFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS)")
  names(settings) <- c("CXX_STD", "PKG_CXXFLAGS", "PKG_LIBS")

  # For each of CXX_STD, PKG_CXXFLAGS, and PKG_LIBS
  for (flag in names(settings)) {
    flag_entry <- which(grepl(flag, makevars))
    if (length(flag_entry) == 0) {
      # If there is no entry for it, set it from our defaults
      makevars <- c(makevars, paste(flag, "=", settings[flag]))
    } else {
      # Otherwise, we get each setting already entered as a vector
      existing_flags <- sub(paste0(flag, "\\s*=\\s*"), "", makevars[flag_entry])
      existing_flags <- unlist(strsplit(existing_flags, " "))
      # Split up our settings as well
      desired_flags <- unlist(strsplit(settings[flag], " "))
      # Get a character vector of length one of
      # (1) first, all the settings they had that we didn't,
      # (2) THEN the settings we need for RcppArmadillo,
      # separated by a space
      desired_flags <- c(setdiff(existing_flags, desired_flags), desired_flags)
      desired_flags <- paste(desired_flags, collapse = " ")
      # And replace that element of makevars
      makevars[flag_entry] <- paste(flag, "=", desired_flags)
    }
  }

  # Then we write it all out
  write_utf8(path, makevars)
}
