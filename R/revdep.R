#' Set up devtools revdep template
#'
#' Add `revdep` directory, git-ignoring the files that you shouldn't
#' check in, and creating a `email.yml` for use `revdep_email`.
#' Run the checks with `revdepcheck::revdep_check()`.
#'
#' @export
#' @inheritParams use_template
use_revdep <- function() {
  use_directory("revdep", ignore = TRUE)
  use_git_ignore("revdep/checks")
  use_git_ignore("revdep/library")

  use_template(
    "revdep-email.yml",
    "revdep/email.yml",
    data = list(name = project_name())
  )

  todo("Run checks with ", code("revdepcheck::revdep_check(num_workers = 4)"))
}
