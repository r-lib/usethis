#' Set up devtools revdep template
#'
#' Add \code{revdep} directory, git-ignoring the files that you shouldn't
#' check in, and creating a \code{email.yml} for use \code{revdep_email}.
#' Run the checks with \code{revdepcheck::revdep_check()}.
#'
#' @export
#' @inheritParams use_template
use_revdep <- function(base_path = ".") {
  use_directory("revdep", ignore = TRUE, base_path = base_path)
  use_git_ignore("revdep/checks", base_path = base_path)
  use_git_ignore("revdep/library", base_path = base_path)

  use_template(
    "revdep-email.yml",
    "revdep/email.yml",
    data = list(name = project_name(base_path)),
    base_path = base_path
  )

  todo("Run checks with `revdepcheck::revdep_check(num_workers = 4)`")
}
