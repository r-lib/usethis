#' Defunct and deprecated functions in usethis
#'
#' These functions have either been deprecated or removed from usethis.
#'
#' @name usethis-defunct
#' @keywords internal
NULL

#' @section `pr_pull_upstream()`:
#' This function has been replaced by [pr_merge_main()].
#' @rdname usethis-defunct
#' @export
pr_pull_upstream <- function() {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "pr_pull_upstream()",
    with = "pr_merge_main()",
  )
}

#' @section `pr_sync()`:
#' Bundling these operations together did not seem justified, in terms of how
#' rarely this comes up and, when it does, how likely merge conflicts are.
#' Users of `pr_sync()` should implement these steps "by hand":
#' * (Check you are on a PR branch)
#' * `pr_pull()`
#' * `pr_merge_main()`, deal with any merge conflicts, if any
#' * `pr_push()`
#' @export
#' @rdname usethis-defunct
pr_sync <- function() {
  details <- glue("
    Sync a PR with:
      * {ui_code('pr_pull()')}
      * {ui_code('pr_merge_main()')}
      * {ui_code('pr_push()')}")
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "pr_sync()",
    details = details
  )
}

#' @section `browse_github_token()`, `browse_github_pat()`:
#' These functions have been replaced by [create_github_token()].
#' @rdname usethis-defunct
#' @export
browse_github_token <- function(...) {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "browse_github_token()",
    with = "create_github_token()"
  )
}

#' @rdname usethis-defunct
#' @export
browse_github_pat <- function(...) {
  lifecycle::deprecate_stop(
    "2.0.0",
    what = "browse_github_pat()",
    with = "create_github_token()"
  )
}


#' @section `github_token()`:
#' All implicit and explicit token discovery routes through [gh::gh_token()]
#' now.
#' @rdname usethis-defunct
#' @export
github_token <- function() {
  details <- glue("
    Call {ui_code('gh::gh_token()')} to retrieve a GitHub personal access token
    Call {ui_code('gh_token_help()')} if you need help getting or configuring \\
    your token")
  lifecycle::deprecate_stop(
    "2.0.0",
    what = "github_token()",
    details = details
  )
}

# git2r ------------------------------------------------------------------------
git2r_explanation <- glue("
  usethis now uses the gert package for Git operations, instead of git2r, and
  gert relies on the credentials package for auth. Therefore git2r credentials
  are no longer accepted.")

deprecate_warn_credentials <- function(whos_asking, details = NULL) {
  whos_asking <- sub("[()]+$", "", whos_asking)
  what <- glue("{whos_asking}(credentials = )")

  lifecycle::deprecate_warn(
    "2.0.0",
    what,
    details = details %||% git2r_explanation
  )
}

#' Produce or register credentials for git2r
#'
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' In usethis v2.0.0, usethis switched from git2r to gert (+ credentials) for
#' all Git operations. This pair of packages (gert + credentials) is designed to
#' discover and use the same credentials as command line Git. As a result, a
#' great deal of credential-handling assistance has been removed from usethis,
#' primarily around SSH keys.
#'
#' If you have credential problems, focus your troubleshooting on getting the
#' credentials package to find your credentials. The [introductory
#' vignette](https://docs.ropensci.org/credentials/articles/intro.html)
#' is a good place to start.
#'
#' If you use the HTTPS protocol (which we recommend), a GitHub personal access
#' token will satisfy all auth needs, for both Git and the GitHub API, and is
#' therefore the easiest approach to get working. See [gh_token_help()] for
#' more.
#'
#' @param protocol Deprecated.
#' @param auth_token Deprecated.
#' @param credentials Deprecated.
#'
#' @return These functions raise a warning and return an invisible `NULL`.
#' @export
git_credentials <- function(protocol = deprecated(),
                            auth_token = deprecated()) {
  lifecycle::deprecate_warn(
    "2.0.0",
    "git_credentials()",
    details = git2r_explanation
  )
  invisible()
}

#' @rdname git_credentials
#' @export
use_git_credentials <- function(credentials = deprecated()) {
  lifecycle::deprecate_warn(
    "2.0.0",
    "use_git_credentials()",
    details = git2r_explanation
  )
  invisible()
}

# repo_spec, host, auth_token --------------------------------------------------
deprecate_warn_host <- function(whos_asking, details = NULL) {
  whos_asking <- sub("[()]+$", "", whos_asking)
  what <- glue("{whos_asking}(host = )")

  host_explanation <- glue("
    usethis now determines the {ui_code('host')} from the current project's \\
    Git remotes.
    The {ui_code('host')} argument is ignored and will eventually be removed.")

  lifecycle::deprecate_warn(
    "2.0.0",
    what,
    details = details %||% host_explanation
  )
}

deprecate_warn_auth_token <- function(whos_asking, details = NULL) {
  whos_asking <- sub("[()]+$", "", whos_asking)
  what <- glue("{whos_asking}(auth_token = )")

  auth_token_explanation <- glue("
    usethis now delegates token lookup to the gh package, which retrieves \\
    credentials based on the targeted host URL.
    This URL is determined by the current project's Git remotes.
    The {ui_code('auth_token')} argument is ignored and will eventually be \\
    removed.")

  lifecycle::deprecate_warn(
    "2.0.0",
    what,
    details = details %||% auth_token_explanation
  )
}

deprecate_warn_repo_spec <- function(whos_asking, details = NULL) {
  whos_asking <- sub("[()]+$", "", whos_asking)
  what <- glue("{whos_asking}(repo_spec = )")

  repo_spec_explanation <- glue("
    usethis now consults the current project's Git remotes to determine the \\
    target repo.
    The {ui_code('repo_spec')} argument is ignored and will eventually be \\
    removed.")

  lifecycle::deprecate_warn(
    "2.0.0",
    what,
    details = details %||% repo_spec_explanation
  )
}
