#' Helpers for GitHub issues
#'
#' @description
#' The `issue_*` family of functions allows you to perform common operations on
#' GitHub issues from within R. They're designed to help you efficiently deal
#' with large numbers of issues, particularly motivated by the challenges faced
#' by the tidyverse team.
#'
#' * `issue_close_community()` closes an issue, because it's not a bug report or
#'   feature request, and points the author towards RStudio Community as a
#'   better place to discuss usage (<https://community.rstudio.com>).
#'
#' * `issue_reprex_needed()` labels the issue with the "reprex" label and
#'   gives the author some advice about what is needed.
#'
#' @section Saved replies:
#'
#' Unlike GitHub's "saved replies", these functions can:
#' * Be shared between people
#' * Perform other actions, like labelling, or closing
#' * Have additional arguments
#' * Include randomness (like friendly gifs)
#'
#' @param number Issue number
#' @param reprex Does the issue also need a reprex?
#'
#' @examples
#' \dontrun{
#' issue_close_community(12)
#'
#' issue_reprex_needed(241, reprex = TRUE)
#' }
#' @name issue-this
NULL

#' @export
#' @rdname issue-this
issue_close_community <- function(number, reprex = FALSE) {
  tr <- target_repo(github_get = TRUE)
  if (!tr$can_push) {
    # https://docs.github.com/en/github/setting-up-and-managing-organizations-and-teams/repository-permission-levels-for-an-organization#repository-access-for-each-permission-level
    # I have not found a way to detect triage permission via API.
    # It seems you just have to try?
    ui_line("
      You don't seem to have push access for {ui_value(tr$repo_spec)}.
      Unless you have triage permissions, you won't be allowed to close an \\
      issue.")
    if (ui_nope("Do you want to try anyway?")) {
      ui_stop("Aborting.")
    }
  }

  info <- issue_info(number, tr)
  issue <- issue_details(info)
  ui_done("
    Closing issue {ui_value(issue$shorthand)} \\
    ({ui_field(issue$author)}): {ui_value(issue$title)}")
  if (info$state == "closed") {
    ui_stop("Issue {number} is already closed")
  }

  reprex_insert <- glue("
    But before you ask there, I'd suggest that you create a \\
    [reprex](https://reprex.tidyverse.org/articles/reprex-dos-and-donts.htm), \\
    because that greatly increases your chances getting help.")

  message <- glue(
    "Hi {issue$author},\n",
    "\n",
    "This issue doesn't appear to be a bug report or a specific feature ",
    "request, so it's more suitable for ",
    "[RStudio Community](https://community.rstudio.com). ",
    if (reprex) reprex_insert else "",
    "\n\n",
    "Thanks!"
  )

  issue_comment_add(number, message = message, tr = tr)
  issue_edit(number, state = "closed", tr = tr)
}

#' @export
#' @rdname issue-this
issue_reprex_needed <- function(number) {
  tr <- target_repo(github_get = TRUE)
  if (!tr$can_push) {
    # https://docs.github.com/en/github/setting-up-and-managing-organizations-and-teams/repository-permission-levels-for-an-organization#repository-access-for-each-permission-level
    # I can't find anyway to detect triage permission via API.
    # It seems you just have to try?
    ui_line("
      You don't seem to have push access for {ui_value(tr$repo_spec)}.
      Unless you have triage permissions, you won't be allowed to label an \\
      issue.")
    if (ui_nope("Do you want to try anyway?")) {
      ui_stop("Aborting.")
    }
  }

  info <- issue_info(number, tr)
  labels <- map_chr(info$labels, "name")
  issue <- issue_details(info)
  if ("reprex" %in% labels) {
    ui_stop("Issue {number} already has 'reprex' label")
  }

  ui_done("
    Labelling and commenting on issue {ui_value(issue$shorthand)} \\
    ({ui_field(issue$author)}): {ui_value(issue$title)}")

  message <- glue("
    Can you please provide a minimal reproducible example using the \\
    [reprex](http://reprex.tidyverse.org) package?
    The goal of a reprex is to make it as easy as possible for me to \\
    recreate your problem so that I can fix it.
    If you've never made a minimal reprex before, there is lots of good advice \\
    [here](https://reprex.tidyverse.org/articles/reprex-dos-and-donts.html).")
  issue_comment_add(number, message = message, tr = tr)
  issue_edit(number, labels = as.list(union(labels, "reprex")), tr = tr)
}

# low-level operations ----------------------------------------------------

issue_comment_add <- function(number, message, tr = NULL) {
  issue_gh(
    "POST /repos/{owner}/{repo}/issues/{issue_number}/comments",
    number = number,
    body = message,
    tr = tr
  )
}

issue_edit <- function(number, ..., tr = NULL) {
  issue_gh(
    "PATCH /repos/{owner}/{repo}/issues/{issue_number}",
    ...,
    number = number,
    tr = tr
  )
}

issue_info <- function(number, tr = NULL) {
  issue_gh(
    "GET /repos/{owner}/{repo}/issues/{issue_number}",
    number = number,
    tr = tr
  )
}

# Helpers -----------------------------------------------------------------

# Assumptions:
# * Issue number is called `issue_number`; make sure to tweak `endpoint` if
#   necessary.
# * The user-facing caller should pass information about the target repo,
#   because that is required to vet the GitHub remote config anyway.
#   The fallback to target_repo() is purely for development convenience.
issue_gh <- function(endpoint, ..., number, tr = NULL) {
  tr <- tr %||% target_repo(github_get = NA)
  gh <- gh_tr(tr)
  out <- gh(endpoint, ..., issue_number = number)
  if (substr(endpoint, 1, 4) == "GET ") {
    out
  } else {
    invisible(out)
  }
}

issue_details <- function(info) {
  repo_dat <- parse_github_remotes(info$html_url)
  list(
    shorthand = glue(
      "{repo_dat$repo_owner}/{repo_dat$repo_name}/#{info$number}"
    ),
    author = glue("@{info$user$login}"),
    title = info$title
  )
}
