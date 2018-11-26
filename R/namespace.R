#' Use a basic `NAMESPACE`
#'
#' This `NAMESPACE` exports everything, except functions that start
#' with a `.`.
#'
#' @seealso The [namespace chapter](http://r-pkgs.had.co.nz/namespace.html) of
#'   [R Packages](http://r-pkgs.had.co.nz).
#'
#' @export
use_namespace <- function() {
  check_is_package("use_namespace()")
  use_template("NAMESPACE")
}

use_namespace_line <- function(namespace, roxygen) {
  if (has_namespace_line(namespace)) {
    return(invisible(FALSE))
  }

  if (uses_roxygen()) {
    r_path <- proj_path("R", paste0(project_name(), "-package"), ext = "R")
    edit_file(r_path)
    todo("Include the following roxygen tags in {value(proj_rel_path(r_path))}")
    code_block(paste0("#' ", roxygen), "NULL")
    todo("Run {code('devtools::document()')}")
  } else {
    edit_file(proj_path("NAMESPACE"))
    todo("Include the following directives in your NAMESPACE")
    code_block(namespace)
  }

  invisible(TRUE)
}

has_namespace_line <- function(x) {
  ns_path <- proj_path("NAMESPACE")
  if (!file_exists(ns_path)) {
    return(FALSE)
  }

  lines <- readLines(ns_path)
  any(grepl(x, lines, fixed = TRUE))
}
