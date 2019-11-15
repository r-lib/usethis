#' Helpers for GitHub issues
#'
#' @description
#' The `issue_*` family of functions allows to perform common operations on
#' GitHub issues from within R. They're designed to help you efficiently deal
#' with large numbers of issues, particularly motived but the challenges faced
#' by the tidyverse team.
#'
#' * `issue_close_community()` closes an issue because it's not a bug report or
#'   features, and points the author towards RStudio community for additional
#'   help.
#'
#' * `issue_reprex_needed()` labels the issue with the "reprex" label and
#'   gives the author some advice about what is needed.
#'
#' @section Saved replies:
#'
#' Compared to saved replies, these functions can:
#' * Be shared between people
#' * Also perform other actions like labelling, or closing.
#' * Have additional arguments.
#' * Include randomness (like friendly gifs)
#' @param number Issue number
#' @param reprex Does the issue also need a reprex?
#' @export
issue_close_community <- function(number, reprex = FALSE) {
  info <- issue_info(number)
  if (info$state == "closed") {
    ui_stop("Issue {number} is already closed")
  }

  message <- glue(
    "Hi @{info$user$login},\n",
    "\n",
    "This issue doesn't appear to be a bug report or a specific feature request, so it's more suitable for [RStudio community](https://community.rstudio.com). ",
    if (reprex) "But before you ask there, I'd suggest that you create a [reprex](https://reprex.tidyverse.org/), because that will greatly increase the chances of you getting help." else "",
    "\n\n",
    "Thanks!"
  )

  issue_comment_add(number, message)
  issue_edit(number, state = "closed")
}

#' @rdname issue_close_community
#' @export
issue_reprex_needed <- function(number) {
  info <- issue_info(number)
  labels <- purrr::map_chr(info$labels, "name")

  if ("reprex" %in% labels) {
    ui_stop("Issue {number} already has 'reprex' label")
  }

  message <- glue(
    "Can you please provide a minimal reproducible example using the [reprex](http://reprex.tidyverse.org) package? ",
    "The goal of a reprex is to make it as easy as possible for me to recreate your problem so that I can fix it. ",
    "If you've never made a minimal reprex before, there is lots of good advice [here](https://reprex.tidyverse.org/articles/reprex-dos-and-donts.html)."
  )
  issue_comment_add(number, message)
  issue_edit(number, labels = as.list(union(labels, "reprex")))
}

# low-level operations ----------------------------------------------------

issue_comment_add <- function(number, message) {
  issue_gh("POST /repos/:owner/:repo/issues/:issue_number/comments", number,
    body = message
  )
}

issue_edit <- function(number, ...) {
  issue_gh("PATCH /repos/:owner/:repo/issues/:issue_number", number, ...)
}

issue_info <- function(number) {
  issue_gh("GET /repos/:owner/:repo/issues/:issue_number", number)
}

# Helpers -----------------------------------------------------------------

# Assumes that the issue number is called issue number, so make sure to tweak
# the endpoint if necessary.
issue_gh <- function(endpoint, number, ...) {
  out <- gh::gh(
    endpoint,
    ...,
    issue_number = number,
    owner = github_owner(),
    repo = github_repo(),
    .token = check_github_token(allow_empty = TRUE)
  )

  if (substr(endpoint, 1, 4) == "GET ") {
    out
  } else {
    invisible(out)
  }
}

