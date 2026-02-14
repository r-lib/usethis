#' Find forks with no open pull requests
#'
#' @description
#' `gh_fork_status()` reports all forks that the current user has, along with
#' the number of open PRs in each.
#'
#' `gh_fork_cleanup()` deletes all forks with zero open PRs.
#'
#' @export
#' @examples
#' \dontrun{
#' # Find and optionally delete forks with no open PRs
#' gh_fork_status()
#' gh_fork_cleanup()
#' }
gh_fork_status <- function() {
  me <- gh::gh_whoami()$login
  # Don't want to use /user/repos, since it returns all repos you have
  # access to, even in other orgs
  repos <- gh::gh(
    "GET /users/{user}/repos/forks",
    user = me,
    visibility = "public",
    per_page = 100,
    .limit = Inf
  )
  is_fork <- map_lgl(repos, \(repo) repo$fork)

  # The /repos endpoint doesn't give us any details about the parent
  # so we now retrieve that
  repo_names <- map_chr(repos, \(repo) repo$name)
  fork_names <- repo_names[is_fork]
  forks <- map(
    fork_names,
    \(name) gh::gh("/repos/{owner}/{repo}", owner = me, repo = name),
    .progress = "Retrieving fork metadata"
  )
  fork_owners <- map_chr(forks, \(fork) fork$parent$owner$login)

  # Now we can see if there are any outstanding PRs
  prs <- purrr::map2(
    fork_owners,
    fork_names,
    gh_repo_open_prs,
    pr_creator = me,
    .progress = "Looking for open PRs"
  )

  data.frame(
    name = fork_owners,
    repo = fork_names,
    open_prs = lengths(prs)
  )
}

#' @export
#' @rdname gh_fork_status
#' @param api_key An API key with `delete_repo` scope. We recommend making
#'   this a very shortlived token.
gh_fork_cleanup <- function(api_key) {
  forks <- gh_fork_status()
  if (nrow(forks) == 0) {
    return(invisible())
  }

  deleteable <- forks[forks$open_prs == 0, ]
  if (nrow(deleteable) == 0) {
    return(invisible())
  }

  cli::cli_inform("Found {nrow(deleteable)} fork{?s} with no open PRs")
  if (!ui_yeah("Delete them?")) {
    return(invisible())
  }

  me <- gh::gh_whoami()$login
  for (i in seq_len(nrow(deleteable))) {
    repo <- deleteable$name[[i]]
    cli::cli_inform("Deleting {me}/{repo}")

    gh::gh(
      "DELETE /repos/{owner}/{repo}",
      owner = me,
      repo = repo,
      .token = api_key
    )
  }

  invisible()
}

# Helpers ---------------------------------------------------------------------

gh_repo_open_prs <- function(fork_owner, fork_name, pr_creator) {
  # Docs advertise `head` param to filter by user/branch, but that
  # didn't work for me.
  prs <- gh::gh(
    "GET /repos/{owner}/{repo}/pulls",
    owner = fork_owner,
    repo = fork_name,
    state = "open",
    # This will miss forks older forks but should be low risk
    per_page = 50
  )
  creator <- map_chr(prs, \(pr) pr$user$login)
  prs[creator == pr_creator]
}
