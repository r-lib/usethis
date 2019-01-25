#' Helpers for GitHub pull requests
#'
#' @description
#' * `pr_init("name")` creates and checks out a new local branch, in
#'    anticipation of making a PR.
#' * `pr_fetch(number)` downloads a remote PR so you can edit locally.
#' * `pr_push()` pushes local changes to GitHub, after checking that there
#'    aren't any remote changes you need to retrieve first. It will create
#'    a PR if needed
#' * `pr_pull()` retrieves changes from the GitHub PR. Run this if others
#'    have made suggestions or pushed into your PR.
#' * `pr_pull_source()` updates your PR with changes from the source
#'    repository
#' * `pr_sync()` is a shortcut for `pr_pull()`, `pr_pull_source()`, and
#'   `pr_push()`
#' * `pr_view()` opens the PR in the browser
#' * `pr_pause()` makes sure you're synched with the PR and then switches
#'    back to master.
#' * `pr_finish()` changes local branch to `master`, pulls new changes, and
#'    deletes the PR branch. Run this from the PR branch after is has been
#'    merged.
#'
#' @details
#' These functions have been designed to support the git and GitHub best
#' practices described in <http://happygitwithr.com/>.
#' @export
#' @param branch branch name. Should usually consist of lower case letters,
#'   numbers, and `-`.
pr_init <- function(branch) {
  check_uses_github()
  check_branch_current("master", "pr_pull_source()")

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
#' @param owner Name of the owner of the repository that is the target of the
#'   pull request. Default of `NULL` uses the source repo.
#'
#' @examples
#' \dontrun{
#' ## scenario: current project is a local copy of fork of a repo owned by
#' ## 'tidyverse', not you
#' pr_fetch(123, owner = "tidyverse")
#' }
pr_fetch <- function(number, owner = NULL) {
  check_uncommitted_changes()

  ui_done("Retrieving data for PR #{number}")
  pr <- gh::gh("GET /repos/:owner/:repo/pulls/:number",
    owner = owner %||% github_source() %||% github_owner(),
    repo = github_repo(),
    number = number
  )

  their_branch <- pr$head$ref
  them <- pr$head$user$login
  if (them == github_owner()) {
    remote <- "origin"
    our_branch <- their_branch
  } else {
    remote <- them
    our_branch <- glue("{them}-{their_branch}")
  }

  if (!remote %in% git2r::remotes(git_repo())) {
    ui_done("Adding remote {ui_value(remote)}")
    git2r::remote_add(git_repo(), remote, pr$head$repo$ssh_url)
  }

  if (!git_branch_exists(our_branch)) {
    their_refname <- git_remref(remote, their_branch)

    ui_done("Creating local branch {ui_value(our_branch)}")
    git2r::fetch(git_repo(), remote, refspec = their_branch, verbose = FALSE)
    git_branch_create(our_branch, their_refname)

    git_branch_track(our_branch, remote, their_branch)

    # Cache URL for PR in config for branch
    config_url <- glue("branch.{our_branch}.pr-url")
    git_config_set(config_url, pr$html_url)

    # `git push` will not work unless `push.default=upstream`; there's no simple
    # way to make it work without substantial drawbacks, due to the design of
    # git. `pr_push()`, however, will always work
  }

  if (git_branch_name() != our_branch) {
    ui_done("Switching to branch {ui_value(our_branch)}")
    git_branch_switch(our_branch)
  }
}

#' @export
#' @rdname pr_init
pr_push <- function() {
  check_uses_github()
  check_branch_not_master()
  check_uncommitted_changes()

  branch <- git_branch_name()
  has_remote_branch <- !is.null(git_branch_tracking(branch))
  if (has_remote_branch) {
    check_branch_current(use = "pr_pull()")
  }

  git_branch_push(branch)

  if (!has_remote_branch) {
    git_branch_track(branch)
  }

  # Prompt to create PR on first push
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
pr_pull_source <- function() {
  check_uses_github()
  check_uncommitted_changes()

  ui_done("Pulling changes from GitHub source repo")
  if (git_is_fork()) {
    git_pull("upstream/master")
  } else {
    git_pull("origin/master")
  }
}

#' @export
#' @rdname pr_init
pr_sync <- function() {
  pr_pull()
  pr_pull_source()
  pr_push()
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
pr_pause <- function() {
  check_branch_not_master()
  check_uncommitted_changes()
  check_branch_current(use = "pr_pull()")

  ui_done("Switching back to {ui_value('master')} branch")
  git_branch_switch("master")
}

#' @export
#' @rdname pr_init
pr_finish <- function() {
  check_branch_not_master()
  pr <- git_branch_name()

  ui_done("Switching back to {ui_value('master')} branch")
  git_branch_switch("master")

  pr_pull_source()

  ui_done("Deleting local {ui_value(pr)} branch")
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
  # Have we done this before? Check if we've cached pr-url in git config.
  config_url <- glue("branch.{branch}.pr-url")
  url <- git_config_get(config_url)
  if (!is.null(url)) {
    return(url)
  }

  if (git_is_fork()) {
    source <- github_source()
    pr_branch <- remref_branch(git_branch_tracking(branch))
  } else {
    source <- github_owner()
    pr_branch <- branch
  }

  urls <- pr_find(source, github_repo(), github_owner(), pr_branch)

  if (length(urls) == 0) {
    NULL
  } else if (length(urls) == 1) {
    git_config_set(config_url, urls[[1]])
    urls[[1]]
  } else {
    ui_stop("Multiple PRs correspond to this branch. Please close before continuing")
  }
}

pr_find <- function(owner, repo, pr_owner = owner, pr_branch = git_branch_name()) {
  # Look at all PRs
  prs <- gh::gh("GET /repos/:owner/:repo/pulls",
    owner = owner,
    repo = repo,
    .limit = Inf
  )

  if (identical(prs[[1]], "")) {
    return(character())
  }

  refs <- purrr::map_chr(prs, c("head", "ref"), .default = NA_character_)
  user <- purrr::map_chr(prs, c("head", "user", "login"), .default = NA_character_)
  urls <- purrr::map_chr(prs, c("html_url"), .default = NA_character_)

  urls[refs == pr_branch & user == pr_owner]
}
