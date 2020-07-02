#' Defunct functions in usethis
#'
#' These functions are marked as defunct and have been removed from usethis.
#'
#' @name usethis-defunct
#' @keywords internal
NULL

#' This function is defunct
#' @rdname usethis-defunct
#' @export
use_depsy_badge <- function() {
  msg <- glue(
    "The Depsy project has officially concluded and is no longer ",
    "being maintained. Therefore {ui_code('use_depsy_badge()')}",
    " has been removed from usethis."
  )
  .Defunct(msg = msg)
}

#' @rdname usethis-defunct
#' @export
pr_pull_upstream <- function() {
  lifecycle::deprecate_stop(
    when = "1.7.0",
    what = "pr_pull_upstream()",
    with = "pr_merge_main()",
  )
}

deprecate_warn_credentials <- function(whos_asking, details = NULL) {
  whos_asking <- sub("[()]+$", "", whos_asking)
  what <- glue("{whos_asking}(credentials = )")

  lifecycle::deprecate_warn(
    "1.7.0",
    "use_github(credentials = )",
    details = details %||% git2r_explanation
  )
}

git2r_explanation <- glue("
    usethis now uses the gert package for Git operations, instead of git2r, and
    gert relies on the credentials package for auth. Therefore git2r credentials
    are no longer accepted.")

#' Produce or register credentials for git2r
#'
#'  \lifecycle{defunct}
#'
#' In usethis v1.7.0, usethis switched from git2r to gert (+ credentials) for
#' all Git operations. This pair of packages (gert + credentials) is designed to
#' discover and use the same credentials as command line Git. As a result, a
#' great deal of credential-handling assistance has been removed from usethis,
#' primarily around SSH keys. If you have credential problems, focus your
#' troubleshooting on getting the credentials package to find your credentials.
#' If you use the HTTPS protocol, a configured `GITHUB_PAT` will satisfy all
#' auth needs, for both Git and the GitHub API, and is therefore the easiest
#' approach to get working.
#'
#' @inheritParams git_protocol
#' @inheritParams use_github
#'
#' @return Invisible `NULL`.
#' @export
git_credentials <- function(protocol = deprecated(),
                            auth_token = deprecated()) {
  lifecycle::deprecate_warn(
    "1.7.0",
    "git_credentials()",
    details = git2r_explanation
  )
}

#' @rdname git_credentials
#' @export
use_git_credentials <- function(credentials) {
  lifecycle::deprecate_warn(
    "1.7.0",
    "use_git_credentials()",
    details = git2r_explanation
  )
}
