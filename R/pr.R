#' Helpers for GitHub pull requests
#'
#' The `pr_*` family of functions is designed to make working with GitHub
#' PRs as painless as possible for both contributors and package maintainers.
#' They are designed to support the git and GitHub best practices described in
#' <http://happygitwithr.com/>.
#'
#' @section Set up advice:
#' These functions make heavy use of git2r and the GitHub API. You'll need a
#' GitHub personal access token (PAT); see [browse_github_token()] for help
#' with that. If git2r does not seem to be finding your git credentials, read
#' [git2r_credentials()] for troubleshooting advice. The transport protocol
#' (SSH vs HTTPS) is determined from the existing remote URL(s) of the repo.
#'
#' @section For contributors:
#' To contribute to a package, first use `create_from_github(owner/repo)` to
#' fork the source repository, and then check out a local copy. Next use
#' `pr_init()` to create a branch for your PR (__never__ submit a PR from the
#' `master` branch). You'll then work locally, making changes to files
#' and checking them into git. Once you're ready to submit, run `pr_push()`
#' to push your local branch to GitHub, and open a webpage that lets you
#' initiate the PR.
#'
#' If you are lucky, your PR will be perfect, and the maintainer will accept
#' it. You can then run `pr_finish()` to close and delete your PR branch.
#' In most cases, however, the maintainer will ask you to make some changes.
#' Make the changes, then run `pr_push()` to sync back up to GitHub.
#'
#' It's also possible that the maintainer will contribute some code to your
#' PR: you get that code back to your computer, run `pr_pull()`. It's also
#' possible that other changes have occured to the package while you've been
#' working on your PR, and you need to "merge master". Do that by running
#' `pr_pull_upstream()`: this makes sure that your copy of the package is
#' up-to-date with the maintainer's latest changes. Either of the pull
#' functions may cause merge conflicts, so be prepared to resolve before
#' continuing.
#'
#' @section For maintainers:
#' To download a PR locally so that you can experiment with it, run
#' `pr_fetch(<pr_number>)`. If you make changes, run `pr_push()` to push
#' them back to GitHub. After you have merged the PR, run `pr_finish()`
#' to delete the local branch.
#'
#' @section Other helpful functions:
#' * `pr_sync()` is a shortcut for `pr_pull()`, `pr_pull_upstream()`, and
#'   `pr_push()`
#' * `pr_pause()` makes sure you're synched with the PR and then switches
#'    back to master.
#' * `pr_view()` opens the PR in the browser
#' @export
#' @param branch branch name. Should usually consist of lower case letters,
#'   numbers, and `-`.
pr_init <- function(branch) {
  check_uses_github()
  check_branch_pulled("master", "pr_pull_upstream()")

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
#'   pull request. Default of `NULL` tries to identify the source repo and uses
#'   the owner of the `upstream` remote, if present, or the owner of `origin`
#'   otherwise.
#'
#' @examples
#' \dontrun{
#' ## scenario: current project is a local copy of fork of a repo owned by
#' ## 'tidyverse', not you
#' pr_fetch(123, owner = "tidyverse")
#' }
pr_fetch <- function(number,
                     owner = NULL) {
  check_uses_github()
  check_uncommitted_changes()

  auth_token <- check_github_token(allow_empty = TRUE)

  owner <- owner %||% github_owner_upstream() %||% github_owner()
  repo <- github_repo()
  pr <- gh::gh(
    "GET /repos/:owner/:repo/pulls/:number",
    owner = owner,
    repo = repo,
    number = number,
    .token = auth_token
  )
  pr_string <- glue("{owner}/{repo}/#{number}")
  pr_user <- glue("@{pr$user$login}")
  ui_done(
    'Checking out PR {ui_value(pr_string)} ({ui_field(pr_user)}): \\
    {ui_value(pr$title)}'
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

  protocol <- github_remote_protocol()

  if (!remote %in% git2r::remotes(git_repo())) {
    url <- switch(
      protocol,
      https = pr$head$repo$clone_url,
      ssh   = pr$head$repo$ssh_url
    )
    ui_done("Adding remote {ui_value(remote)} as {ui_value(url)}")
    git2r::remote_add(git_repo(), remote, url)
  }

  if (!git_branch_exists(our_branch)) {
    their_refname <- git_remref(remote, their_branch)
    credentials <- git2r_credentials(protocol, auth_token)
    ui_done("Creating local branch {ui_value(our_branch)}")
    git2r::fetch(
      git_repo(),
      name = remote,
      credentials = credentials,
      refspec = their_branch,
      verbose = FALSE
    )
    git_branch_create(our_branch, their_refname)
    git_branch_track(our_branch, remote, their_branch)

    # Cache URL for PR in config for branch
    config_url <- glue("branch.{our_branch}.pr-url")
    git_config_set(config_url, pr$html_url)

    # `git push` will not work if the branch names differ, unless
    # `push.default=upstream`; there's no simple way to make it work without
    # drawbacks, due to the design of git. `pr_push()`, however, will always
    # work.
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
    check_branch_pulled(use = "pr_pull()")
  }

  remote_info <- git_branch_remote(branch)
  protocol <- github_remote_protocol(remote_info$remote_name)
  credentials <- git2r_credentials(protocol)

  git_branch_push(branch, credentials = credentials)

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

  protocol <- github_remote_protocol()
  credentials <- git2r_credentials(protocol)

  ui_done("Pulling changes from GitHub PR")
  git_pull(credentials = credentials)

  invisible(TRUE)
}

#' @export
#' @rdname pr_init
pr_pull_upstream <- function() {
  check_uses_github()
  check_uncommitted_changes()

  branch <- "master"
  remote <- if (git_is_fork()) "upstream" else "origin"
  source <- git_remref(remote, branch)

  protocol <- github_remote_protocol(remote)
  credentials <- git2r_credentials(protocol)

  ui_done("Pulling changes from GitHub source repo {ui_value(source)}")
  git_pull(source, credentials = credentials)
}

#' @export
#' @rdname pr_init
pr_sync <- function() {
  pr_pull()
  pr_pull_upstream()
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
  check_branch_pulled(use = "pr_pull()")

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

  pr_pull_upstream()

  # TODO: check that this is merged!
  ui_done("Deleting local {ui_value(pr)} branch")
  git_branch_delete(pr)
}

pr_create_gh <- function() {
  owner <- github_owner()
  repo <- github_repo()
  branch <- git_branch_name()

  ui_done("Create PR at link given below")
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
    source <- github_owner_upstream()
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

pr_find <- function(owner,
                    repo,
                    pr_owner = owner,
                    pr_branch = git_branch_name()) {
  # Look at all PRs
  prs <- gh::gh("GET /repos/:owner/:repo/pulls",
    owner = owner,
    repo = repo,
    .limit = Inf,
    .token = check_github_token(allow_empty = TRUE)
  )

  if (identical(prs[[1]], "")) {
    return(character())
  }

  refs <- purrr::map_chr(prs, c("head", "ref"), .default = NA_character_)
  user <- purrr::map_chr(prs, c("head", "user", "login"), .default = NA_character_)
  urls <- purrr::map_chr(prs, c("html_url"), .default = NA_character_)

  urls[refs == pr_branch & user == pr_owner]
}
