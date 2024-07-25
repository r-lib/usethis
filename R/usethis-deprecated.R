#' Deprecated Git functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' * `git_branch_default()` has been replaced by [git_default_branch()].
#'
#' @keywords internal
#' @export
git_branch_default <- function() {
  lifecycle::deprecate_soft("2.1.0", "git_branch_default()", "git_default_branch()")
  git_default_branch()
}

#' Deprecated tidyverse functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' * `use_tidy_eval()` is deprecated because there's no longer a need to
#'    systematically import and re-export a large number of functions in order
#'    to use tidy evaluation. Instead, use [use_import_from()] to tactically
#'    import functions as you need them.
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

# GitHub actions --------------------------------------------------------------

#' Deprecated GitHub Actions functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' * `use_github_actions()` is deprecated because it was just an alias
#'   for [use_github_action_check_release()].
#'
#' * `use_github_action_check_full()` is overkill for most packages and is
#'    not recommended.
#'
#' * `use_github_action_check_release()`, `use_github_action_check_standard()`,
#'   and `use_github_action_pr_commands()` are deprecated in favor of
#'   [use_github_action()], which can now suggest specific workflows to use.
#'
#' @export
#' @keywords internal
use_github_actions <- function() {
  lifecycle::deprecate_warn(
    when = "2.2.0",
    what = "use_github_actions()",
    with = "use_github_action('check-release')"
  )
  use_github_action('check-release')
}

#' @rdname use_github_actions
#' @export
use_github_action_check_release <- function(save_as = "R-CMD-check.yaml",
                                            ref = NULL,
                                            ignore = TRUE,
                                            open = FALSE) {

  lifecycle::deprecate_warn(
    when = "2.2.0",
    what = "use_github_action_check_release()",
    with = "use_github_action('check-release')"
  )

  use_github_action(
    "check-release.yaml",
    ref = ref,
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge(save_as)
}

#' @rdname use_github_actions
#' @export
use_github_action_check_standard <- function(save_as = "R-CMD-check.yaml",
                                             ref = NULL,
                                             ignore = TRUE,
                                             open = FALSE) {
  lifecycle::deprecate_warn(
    when = "2.2.0",
    what = "use_github_action_check_standard()",
    with = "use_github_action('check-standard')"
  )

  use_github_action(
    "check-standard.yaml",
    ref = ref,
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge(save_as)
}

#' @rdname use_github_actions
#' @export
use_github_action_pr_commands <- function(save_as = "pr-commands.yaml",
                                          ref = NULL,
                                          ignore = TRUE,
                                          open = FALSE) {
  lifecycle::deprecate_warn(
    when = "2.2.0",
    what = "use_github_action_pr_commands()",
    with = "use_github_action('pr-commands')"
  )

  use_github_action(
    "pr-commands.yaml",
    ref = ref,
    save_as = save_as,
    ignore = ignore,
    open = open
  )
}

#' @rdname use_github_actions
#' @export
use_github_action_check_full <- function(save_as = "R-CMD-check.yaml",
                                         ignore = TRUE,
                                         open = FALSE,
                                         repo_spec = NULL) {
  details <- glue("
    It is overkill for the vast majority of R packages.
    The \"check-full\" workflow is among those configured by \\
    `use_tidy_github_actions()`.
    If you really want it, request it by name with `use_github_action()`.")
  lifecycle::deprecate_stop(
    "2.1.0",
    "use_github_action_check_full()",
    details = details
  )
}
