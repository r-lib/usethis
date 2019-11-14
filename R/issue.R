issue_close_community <- function(number, reprex = FALSE) {
  info <- issue_info(number)

  message <- glue(
    "Hi @{info$user$login},\n",
    "\n",
    "This issue doesn't appear to be a bug report or a specific feature request, so it's more suitable for [RStudio community](https://community.rstudio.com). ",
    if (reprex) "But before you ask there, I'd suggest that you create a [reprex](https://reprex.tidyverse.org/), because that will greatly increase the chances of you getting help." else "",
    "\n\n",
    "Thanks!"
  )

  issue_close(number, message)
}

issue_comment_add <- function(number, message) {
  message <- paste0(message, collape = "")

  issue_gh("POST /repos/:owner/:repo/issues/:issue_number/comments", number,
    body = message
  )
}

issue_close <- function(number, message) {
  if (!is.null(message)) {
    issue_comment_add(number, message)
  }

  issue_gh("PATCH /repos/:owner/:repo/issues/:issue_number", number,
    state = "closed"
  )
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

