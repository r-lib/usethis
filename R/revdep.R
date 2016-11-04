#' Set up devtools revdep template
#'
#' Add \code{revdep} directory and basic check template.
#' @export
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
