#' Helpers for GitHub pull requests
#'
#' @description
#' * `pr_init("name")` creates a new local branch for a PR.
#' * `pr_fetch(number)` downloads a remote PR so you can edit locally.
#' * `pr_push()` pushes local changes to GitHub, after checking that there
#'    aren't any remote changes you need to retrieve first. On first use,
#'    it will prompt you to create a PR on GitHub.
#' * `pr_pull()` retrives changes from the GitHub PR. Run this if others
#'    have made suggestions or pushed into your PR.
#' * `pr_view()` open the PR in the browser
#'
#' @details
#' These functions have been designed to support the git and GitHub best
#' practices described in <http://happygitwithr.com/>.
#' @export
#' @param branch branch name. Should usually consist of lower case letters,
#'   numbers, and `-`.
pr_init <- function(branch) {
  check_uses_github()
  check_branch_current("master")

  if (!git_branch_exists(branch)) {
    if (git_branch_name() != "master") {
      if (ui_nope("Create local PR branch with non-master parent?")) {
        return(invisible(FALSE))
      }
    }

    ui_done("Creating local PR branch {ui_value(branch)}")
    git_branch_create(branch)
  }

  if (git_branch_name() != branch) {
    ui_done("Switching to branch {ui_value(branch)}")
    git_branch_switch(branch)
  }

  ui_todo("Use {ui_code('pr_push()')} to create PR")
  invisible()
}

#' @export
#' @rdname pr_init
#' @param number Number of PR to fetch.
pr_fetch <- function(number) {
  check_branch_current("master")
  check_uncommitted_changes()

  ui_done("Retrieving PR data")
  pr <- gh::gh("GET /repos/:owner/:repo/pulls/:number",
    owner = github_owner(),
    repo = github_repo(),
    number = number
  )

  ref <- pr$head$ref
  user <- pr$head$user$login
  if (user == github_owner()) {
    user <- "origin"
    branch <- ref
  } else {
    branch <- paste0(user, "-", ref)
  }
  remote <- paste0(user, "/", ref)

  if (!user %in% git2r::remotes(git_repo())) {
    ui_done("Adding remote {ui_value(remote)}")
    git2r::remote_add(git_repo(), user, pr$head$repo$ssh_url)
  }

  if (!git_branch_exists(branch)) {
    ui_done("Creating local branch {ui_value(branch)}")
    git2r::fetch(git_repo(), user, refspec = ref, verbose = FALSE)
    git_branch_create(branch, remote)
    git_branch_track(branch, user, ref)
  }

  if (git_branch_name() != branch) {
    ui_done("Switching to branch {ui_value(branch)}")
    git_branch_switch(branch)
  }
}

#' @export
#' @rdname pr_init
pr_push <- function() {
  check_uses_github()
  check_branch_not_master()
  check_uncommitted_changes()

  branch <- git_branch_name()
  has_remote <- !is.null(git_branch_remote(branch))
  if (has_remote) {
    check_branch_current()
  }

  ui_done("Pushing changes to GitHub PR")
  git_branch_push(branch)

  if (!has_remote) {
    ui_done("Tracking remote PR branch")
    git_branch_track(branch)
  }

  # Prompt to create on first push
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    ui_done("View PR at {ui_value(url)}")
  }
}

#' @export
#' @rdname pr_init
pr_pull <- function() {
  check_uses_github()
  check_branch_not_master()
  check_uncommitted_changes()

  ui_done("Pulling changes from GitHub PR")
  git_pull()

  invisible(TRUE)
}

#' @export
#' @rdname pr_init
pr_view <- function() {
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    view_url(pr_url())
  }
}

#' @export
#' @rdname pr_init
pr_finish <- function() {
  check_branch_not_master()
  pr <- git_branch_name()

  ui_done("Switching back to master branch")
  git_branch_switch("master")

  ui_done("Pulling changes from GitHub")
  git_pull()

  ui_done("Deleting local {pr} branch")
  git_branch_delete(pr)
}

pr_create_gh <- function() {
  owner <- github_owner()
  repo <- github_repo()
  branch <- git_branch_name()

  ui_done("Create PR at:")
  view_url(glue("https://github.com/{owner}/{repo}/compare/{branch}"))
}

pr_url <- function(branch = git_branch_name()) {
  # Look first in cache (stored in git config)
  config_url <- glue("branch.{branch}.pull-url")
  url <- git_config_get(config_url)
  if (!is.null(url)) {
    return(url)
  }

  urls <- pr_find(github_owner(), github_repo(), branch)

  if (length(urls) == 0) {
    NULL
  } else if (length(urls) == 1) {
    git_config_set(config_url, urls[[1]])
    urls[[1]]
  } else {
    ui_stop("Multiple PRs correspond to this branch. Please close before continuing")
  }
}

pr_find <- function(owner, repo, branch = git_branch_name()) {
  # Look at all PRs
  prs <- gh::gh("GET /repos/:owner/:repo/pulls",
    owner = owner,
    repo = repo,
    head = paste0(owner, ":", branch)
  )
  if (identical(prs[[1]], "")) {
    return(character())
  }

  refs <- purrr::map_chr(prs, c("head", "ref"), .default = NA_character_)
  urls <- purrr::map_chr(prs, c("html_url"), .default = NA_character_)

  urls[refs == branch]
}
