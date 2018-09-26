#' Use RcppArmadillo
#'
#' Creates `src/`, adds needed packages to `DESCRIPTION`,
#' and configures `src/Makevars` and `src/Makevars.win`.
#'
#' @export
use_rcpp_armadillo <- function() {

  check_is_package("use_rcpp_armadillo()")

  use_dependency("Rcpp", "LinkingTo")
  use_dependency("RcppArmadillo", "LinkingTo")
  use_dependency("Rcpp", "Imports")

  use_directory("src")
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src")

  makevars_path <- proj_path("src/Makevars")
  makevars_win_path <- proj_path("src/Makevars.win")

  set_makevars(makevars_path)
  done("Adding RcppArmadillo settings to {value(makevars_path)}")
  set_makevars(makevars_win_path)
  done("Adding RcppArmadillo settings to {value(makevars_win_path)}")

  if (uses_roxygen()) {
    todo("Include the following roxygen tags somewhere in your package")
    code_block(
      "#' @useDynLib {project_name()}, .registration = TRUE",
      "#' @importFrom Rcpp sourceCpp",
      "NULL"
    )
  } else {
    todo("Include the following directives in your NAMESPACE")
    code_block(
      "useDynLib('{project_name()}', .registration = TRUE)",
      "importFrom('Rcpp', 'sourceCpp')"
    )
    edit_file(proj_path("NAMESPACE"))
  }

  todo("Run {code('devtools::document()')}")
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
