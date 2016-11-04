#' @rdname infrastructure
#' @section \code{use_revdep}:
#' Add \code{revdep} directory and basic check template.
#' @export
#' @aliases add_travis
use_revdep <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_directory("revdep", ignore = TRUE, pkg = pkg)
  use_template(
    "revdep.R",
    "revdep/check.R",
    data = list(name = pkg$package),
    pkg = pkg
  )
  use_git_ignore(revdep_cache_path_raw(""), pkg = pkg)
}
