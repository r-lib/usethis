#' Set up devtools revdep template
#'
#' Add \code{revdep} directory and basic check template.
#'
#' @export
use_revdep <- function(base_path = ".") {
  use_directory("revdep", ignore = TRUE, base_path = base_path)
  use_git_ignore("revdep/.cache.rds", base_path = base_path)

  use_template(
    "revdep.R",
    "revdep/check.R",
    data = list(name = project_name(base_path)),
    base_path = base_path
  )
}
