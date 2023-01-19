#' Defunct PR functions
#'
#' @description
#' `r lifecycle::badge("defunct")`
#'
#' * `pr_pull_upstream()` has been replaced by [pr_merge_main()].
#' * `pr_sync()` has been replaced by [pr_pull()] + [pr_merge_main()] + [pr_push()]
#'
#' @keywords internal
#' @export
pr_pull_upstream <- function() {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "pr_pull_upstream()",
    with = "pr_merge_main()",
  )
}

#' @rdname pr_pull_upstream
#' @export
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

#' Defunct GitHub functions
#'
#' @description
#' `r lifecycle::badge("defunct")`
#'
#' * `browse_github_token()` and `browse_github_pat()` have been replaced by
#'    [create_github_token()].
#' * `github_token()` has been replaced by [gh::gh_token()]
#' * `git_branch_default()` has been replaced by [git_default_branch()].
#' * `use_github_action_check_full()` is overkill for most packages and is
#'    not recommended.
#'
#' @keywords internal
#' @export
browse_github_token <- function(...) {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "browse_github_token()",
    with = "create_github_token()"
  )
}

#' @rdname browse_github_token
#' @export
browse_github_pat <- function(...) {
  lifecycle::deprecate_stop(
    "2.0.0",
    what = "browse_github_pat()",
    with = "create_github_token()"
  )
}

#' @rdname browse_github_token
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

#' @rdname browse_github_token
#' @export
git_branch_default <- function() {
  lifecycle::deprecate_soft("2.1.0", "git_branch_default()", "git_default_branch()")
  git_default_branch()
}

#' @rdname browse_github_token
#' @export
use_github_action_check_full <- function(save_as = "R-CMD-check.yaml",
                                         ignore = TRUE,
                                         open = FALSE,
                                         repo_spec = NULL) {
  details <- glue("
    It is overkill for the vast majority of R packages.
    The \"check-full\" workflow is among those configured by \\
    {ui_code('use_tidy_github_actions()')}.
    If you really want it, request it by name with \\
    {ui_code('use_github_action()')}.")
  lifecycle::deprecate_stop(
    "2.1.0",
    "use_github_action_check_full()",
    details = details
  )
}

#' Defunct tidyverse functions
#'
#' @description
#' `r lifecycle::badge("defunct")`
#'
#' * `use_tidy_labels()` has been replaced by [use_tidy_github_labels()].
#' * `use_tidy_ci()` has been replaced by [use_tidy_github_actions()].
#' * `use_tidy_eval()` is defunct because there's no longer a need to
#'    systematically import and re-export a large number of functions in order
#'    to use tidy evaluation. Instead, use [use_import_from()] to tactically
#'    import functions as you need them.
#'
#' @keywords internal
#' @export
use_tidy_labels <- function() {
  lifecycle::deprecate_stop("2.1.0", "use_tidy_labels()", "use_tidy_github_labels()")
}

#' @rdname use_tidy_labels
#' @export
use_tidy_ci <- function(...) {
  lifecycle::deprecate_stop("2.1.0", "use_tidy_ci()", "use_tidy_github_actions()")
}

#' @rdname use_tidy_labels
#' @keywords internal
#' @export
use_tidy_eval <- function() {
  lifecycle::deprecate_stop(
    "2.2.0",
    "use_tidy_eval()",
    details = c(
      "There is no longer a need to systematically import and/or re-export functions",
      "Instead import functions as needed, with e.g.:",
      'usethis::use_import_from("rlang", c(".data", ".env"))'
    )
  )
}

#' Defunct git2r functions
#'
#' @description
#' `r lifecycle::badge("defunct")`
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
  lifecycle::deprecate_stop(
    "2.0.0",
    "git_credentials()",
    details = git2r_explanation
  )
  invisible()
}

#' @rdname git_credentials
#' @export
use_git_credentials <- function(credentials = deprecated()) {
  lifecycle::deprecate_stop(
    "2.0.0",
    "use_git_credentials()",
    details = git2r_explanation
  )
  invisible()
}

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


# ci ----------------------------------------------------------------------


#' CI on Travis and Appveyor
#'
#' @description
#' `r lifecycle::badge("defunct")`
#'
#' These functions which formally supported CI on Appveyor and Travis are
#' now defunct as we no longer recommend using these services. We now
#' recommend using GitHub actions, e.g. with [use_github_actions()].
#'
#' @export
#' @keywords internal
use_travis <- function(browse = rlang::is_interactive(),
                       ext = c("com", "org")) {

  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "use_travis()",
    with = "use_github_actions()"
  )
}

#' @export
#' @rdname use_travis
use_travis_badge <- function(ext = c("com", "org"), repo_spec = NULL) {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "use_travis_badge()"
  )
}

#' @export
#' @rdname use_travis
use_appveyor <- function(browse = rlang::is_interactive()) {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "use_appveyor()",
    with = "use_github_actions()"
  )
}

#' @export
#' @rdname use_travis
use_appveyor_badge <- function(repo_spec = NULL) {
  lifecycle::deprecate_stop(
    when = "2.0.0",
    what = "use_appveyor_badge()",
  )
}

