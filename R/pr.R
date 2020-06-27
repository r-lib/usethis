#' Helpers for GitHub pull requests
#'
#' @description
#' The `pr_*` family of functions is designed to make working with GitHub pull
#' requests (PRs) as painless as possible for both contributors and package
#' maintainers. They are designed to support the Git and GitHub best practices
#' described in [Happy Git and GitHub for the useR](https://happygitwithr.com).
#' To use the `pr_*` functions, your project must be a Git repo and have one of
#' these GitHub remote configurations:
#' * "ours": You can push to the GitHub remote configured as `origin`. It's not
#'   a fork.
#' * "fork": You can push to the GitHub remote configured as `origin`, it's a
#'   fork, and its parent is configured as `upstream`.
#'
#' "Ours" and "fork" are two of several GitHub remote configurations examined in
#' [Common remote setups](https://happygitwithr.com/common-remote-setups.html)
#' in Happy Git.
#'
#' @section Required setup:
#' The `pr_*` functions interact with GitHub both as a conventional Git remote
#' and via the REST API. Therefore, your credentials must be discoverable. Which
#' credentials do we mean?
#' * A GitHub personal access token (PAT) must be configured as the `GITHUB_PAT`
#' environment variable. [create_github_token()] helps you do this. This PAT
#' allows usethis to call the GitHub API on your behalf. If you use HTTPS
#' remotes, the PAT is also used for, e.g., `git push`. That means the PAT is
#' all you need to setup! Highly recommended for those new to Git and GitHub and
#' PRs.
#' * If you use SSH remotes, your SSH keys must also be discoverable.
#'
#' Usethis uses the gert package for Git operations
#' (<https://docs.ropensci.org/gert>) and gert, in turn, relies on the
#' credentials package (<https://docs.ropensci.org/credentials/>) for auth. If
#' you have credential problems, focus your troubleshooting on getting the
#' credentials package to find your credentials.
#'
#' If the `pr*` functions need to configure a new remote, its transport protocol
#' (HTTPS vs SSH) is determined by the protocol used for `origin`.
#'
#' @section For contributors:
#' To contribute to a package, first use `create_from_github("OWNER/REPO", fork
#' = TRUE)` to fork the source repository, and then check out a local copy.
#'
#' Next use `pr_init()` to create a branch for your PR. It is best practice to
#' never make commits to the `master` (or default) branch of a fork, because you
#' do not own it. A pull request should always come from a feature branch. It
#' will be much easier to pull upstream changes from the fork parent if you only
#' allow yourself to work in feature branches. It is also much easier for a
#' maintainer to explore and extend your PR if you create a feature branch.
#'
#' Work locally, in your branch, making changes to files, and committing your
#' work. Once you're ready to create the PR, run `pr_push()` to push your local
#' branch to GitHub, and open a webpage that lets you initiate the PR (or draft
#' PR).
#'
#' To learn more about the process of making a pull request, read the [Pull
#' Request
#' Helpers](https://usethis.r-lib.org/articles/articles/pr-functions.html)
#' vignette.
#'
#' If you are lucky, your PR will be perfect, and the maintainer will accept it.
#' You can then run `pr_finish()` to close and delete your PR branch. In most
#' cases, however, the maintainer will ask you to make some changes. Make the
#' changes, then run `pr_push()` to sync back up to GitHub.
#'
#' It's also possible that the maintainer will contribute some code to your PR:
#' to get that code back to your computer, run `pr_pull()`. It can also happen
#' that other changes have occurred in the package since you first created your
#' PR. You might need to merge the `master` (or default) branch into your PR
#' branch. Do that by running `pr_pull_upstream()`: this makes sure that your
#' copy of the package is up-to-date with the maintainer's latest changes. Both
#' `pr_pull()` and `pr_pull_upstream()` can result in merge conflicts, so be
#' prepared to resolve before continuing.
#'
#' @section For maintainers:
#' To download a PR locally so that you can experiment with it, run
#' `pr_fetch(<pr_number>)`. If you make changes, run `pr_push()` to push them
#' back to GitHub. After you have merged the PR, run `pr_finish()` to delete the
#' local branch and remove the remote associated with the contributor's fork.
#'
#' @section Other helpful functions:
#' * `pr_resume()` helps you switch to an existing branch and resume work on a
#'   PR.
#' * `pr_sync()` is a shortcut for `pr_pull()`, `pr_pull_upstream()`, and
#' `pr_push()`.
#' * `pr_pause()` makes sure you're synced with the PR and then switches back to
#'   master.
#' * `pr_view()` opens the PR in the browser.
#'
#' @name pull-requests
NULL

#' @export
#' @rdname pull-requests
#' @param branch branch name. Should usually consist of lower case letters,
#'   numbers, and `-`.
pr_init <- function(branch) {
  on.exit(rstudio_git_tickle(), add = TRUE)
  stopifnot(is_string(branch))

  if (git_branch_exists(branch)) {
    code <- glue("pr_resume(\"{branch}\")")
    ui_info("
      Branch {ui_value(branch)} already exists, calling {ui_code(code)}")
    return(pr_resume(branch))
  }

  check_pr_readiness()
  # TODO(@jennybc): if no internet, could offer option to proceed anyway
  # Error in git2r::fetch(repo, name = remref_remote(remref), refspec = branch,  :
  # Error in 'git2r_remote_fetch': failed to resolve address for github.com: nodename nor servname provided, or not known

  if (git_branch() != "master") {
    if (ui_nope("Create local PR branch with non-master parent?")) {
      return(invisible(FALSE))
    }
  }

  check_no_uncommitted_changes(untracked = TRUE)
  pr_pull_from_primary()

  ui_done("Creating and switching to local branch {ui_value(branch)}")
  git_branch_create_and_switch(branch)
  config_key <- glue("branch.{branch}.created-by")
  gert::git_config_set(config_key, "usethis::pr_init", git_repo())

  ui_todo("Use {ui_code('pr_push()')} to create PR.")
  invisible()
}

#' @export
#' @rdname pull-requests
pr_resume <- function(branch = NULL) {
  on.exit(rstudio_git_tickle(), add = TRUE)
  if (is.null(branch)) {
    ui_stop("
      Interactive PR selection not implemented yet.
      For now, {ui_code('branch')} should be the name of a local branch.")
  }
  stopifnot(is_string(branch))
  if (!git_branch_exists(branch)) {
    ui_stop("No local branch named {ui_value('branch')} exists.")
  }

  check_pr_readiness()
  check_no_uncommitted_changes(untracked = TRUE)
  pr_pull_from_primary()

  ui_done("Switching to branch {ui_value(branch)}")
  git_branch_switch(branch)
  upstream <- git_branch_upstream()
  if (!is.na(upstream)) {
    # TODO: I am tempted to add rebase = TRUE here
    gert::git_pull(repo = git_repo())
  }

  ui_todo("Use {ui_code('pr_push()')} to create or update PR.")
  invisible()
}

#' @export
#' @rdname pull-requests
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
  check_pr_readiness()
  check_no_uncommitted_changes()

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
    "Checking out PR {ui_value(pr_string)} ({ui_field(pr_user)}): \\
    {ui_value(pr$title)}"
  )

  their_branch <- pr$head$ref
  them <- pr$head$user$login
  if (them == github_owner()) {
    remote <- "origin"
    our_branch <- their_branch
  } else {
    remote <- them
    our_branch <- glue("{them}-{their_branch}")
    if (!isTRUE(pr$maintainer_can_modify)) {
      ui_info("
      Note that user does NOT allow maintainer to modify this PR \\
      at this time,
      although this can be changed.
      ")
    }
  }

  protocol <- github_remote_protocol()

  if (!remote %in% git2r::remotes(git2r_repo())) {
    url <- switch(
      protocol,
      https = pr$head$repo$clone_url,
      ssh   = pr$head$repo$ssh_url
    )

    if (is.null(url)) {
      ui_stop("No remote found. Has repo been deleted?")
    }

    ui_done("Adding remote {ui_value(remote)} as {ui_value(url)}")
    git2r::remote_add(git2r_repo(), remote, url)
    config_key <- glue("remote.{remote}.created-by")
    gert::git_config_set(config_key, "usethis::pr_fetch", git_repo())
  }

  if (!git_branch_exists(our_branch)) {
    their_refname <- glue("{remote}/{their_branch}")
    credentials <- git_credentials(protocol, auth_token)
    ui_done("Creating and switching to local branch {ui_value(our_branch)}")
    git2r::fetch(
      git2r_repo(),
      name = remote,
      credentials = credentials,
      refspec = their_branch,
      verbose = FALSE
    )
    git_branch_create_and_switch(our_branch, their_refname)
    git_branch_track(our_branch, remote, their_branch)

    config_key <- glue("branch.{our_branch}.created-by")
    gert::git_config_set(config_key, "usethis::pr_fetch", git_repo())

    # Cache URL for PR in config for branch
    config_url <- glue("branch.{our_branch}.pr-url")
    gert::git_config_set(config_url, pr$html_url, git_repo())

    # `git push` will not work if the branch names differ, unless
    # `push.default=upstream`; there's no simple way to make it work without
    # drawbacks, due to the design of git. `pr_push()`, however, will always
    # work.
  }

  if (git_branch() != our_branch) {
    ui_done("Switching to branch {ui_value(our_branch)}")
    git_branch_switch(our_branch)
    pr_pull()
  }
}

#' @export
#' @rdname pull-requests
pr_push <- function() {
  check_pr_readiness()
  check_branch_not_master()
  check_no_uncommitted_changes()

  branch <- git_branch()
  has_remote_branch <- !is.null(git_branch_tracking_FIXME(branch))
  if (has_remote_branch) {
    check_branch_pulled(use = "pr_pull()")
  }

  remote_info <- git_branch_remote(branch)
  protocol <- github_remote_protocol(remote_info$remote_name)
  credentials <- git_credentials(protocol)

  # TODO: I suspect the tryCatch (and perhaps the git_branch_compare()?) is
  # better pushed down into git_branch_push(), which could then return TRUE for
  # success and FALSE for failure
  tryCatch(
    git_branch_push(branch, credentials = credentials),
    error = function(e) {
      ui_stop(c(
        "Push errored",
        "Check that the PR branch is editable, then check your git2r config"
      ))
    }
  )
  if (!has_remote_branch) {
    git_branch_track(branch)
  }

  diff <- git_branch_compare(branch)
  if (diff[[1]] != 0) {
    ui_stop(c(
      "Push failed to update remote branch",
      "Check that the PR branch is editable, then check your git2r config"
    ))
  }

  # Prompt to create PR on first push
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    ui_done("View PR at {ui_value(url)} or call {ui_code('pr_view()')}")
  }

  invisible()
}

#' @export
#' @rdname pull-requests
pr_pull <- function() {
  check_pr_readiness()
  check_branch_not_master()
  check_no_uncommitted_changes()

  protocol <- github_remote_protocol()
  credentials <- git_credentials(protocol)

  ui_done("Pulling changes from GitHub PR")
  git_pull(credentials = credentials)

  invisible(TRUE)
}

#' @export
#' @rdname pull-requests
pr_pull_upstream <- function() {
  check_pr_readiness()
  check_no_uncommitted_changes()

  branch <- "master"
  remote <- if (git_is_fork()) "upstream" else "origin"
  source <- glue("{remote}/{branch}")

  protocol <- github_remote_protocol(remote)
  credentials <- git_credentials(protocol)

  ui_done("Pulling changes from GitHub source repo {ui_value(source)}")
  git_pull(source, credentials = credentials)
}

#' @export
#' @rdname pull-requests
pr_sync <- function() {
  check_pr_readiness()
  pr_pull()
  pr_pull_upstream()
  pr_push()
}

#' @export
#' @rdname pull-requests
pr_view <- function() {
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    view_url(pr_url())
  }
}

#' @export
#' @rdname pull-requests
pr_pause <- function() {
  check_pr_readiness()
  check_branch_not_master()
  check_no_uncommitted_changes()
  check_branch_pulled(use = "pr_pull()")

  ui_done("Switching back to {ui_value('master')} branch")
  git_branch_switch("master")
  pr_pull_upstream()
}

#' @export
#' @rdname pull-requests
pr_finish <- function(number = NULL) {
  check_pr_readiness()
  repo <- git_repo()

  if (!is.null(number)) {
    pr_fetch(number)
  }

  check_branch_not_master()
  check_no_uncommitted_changes()

  tracking_branch <- git_branch_tracking()
  if (!is.null(tracking_branch)) {
    check_branch_pushed(use = "pr_push()")
  }

  pr <- git_branch()

  ui_done("Switching back to {ui_value('master')} branch")
  git_branch_switch("master")
  pr_pull_upstream()

  ui_done("Deleting local {ui_value(pr)} branch")
  gert::git_branch_delete(pr, repo = repo)

  if (is.null(tracking_branch)) {
    return(invisible())
  }

  remote <- remref_remote(tracking_branch)
  created_by <- git_cfg_get(glue("remote.{remote}.created-by"))
  if (is.null(created_by) || !grepl("^usethis::pr_", created_by)) {
    return(invisible())
  }

  b <- git2r::branches(git2r_repo(), flags = "local")
  remote_specs <- purrr::map(b, ~ git2r::branch_get_upstream(.x)$name)
  remote_specs <- purrr::compact(remote_specs)
  if (sum(grepl(glue("^{remote}/"), remote_specs)) == 0) {
    ui_done("Removing remote {ui_value(remote)}")
    git2r::remote_remove(git2r_repo(), remote)
  }
}

pr_create_gh <- function() {
  owner <- github_owner()
  repo <- github_repo()
  branch <- git_branch()

  ui_done("Create PR at link given below")
  view_url(glue("https://github.com/{owner}/{repo}/compare/{branch}"))
}

pr_url <- function(branch = git_branch()) {
  # Have we done this before? Check if we've cached pr-url in git config.
  config_url <- glue("branch.{branch}.pr-url")
  url <- git_cfg_get(config_url)
  if (!is.null(url)) {
    return(url)
  }

  if (git_is_fork()) {
    source <- github_owner_upstream()
    pr_branch <- remref_branch(git_branch_tracking_FIXME(branch))
  } else {
    source <- github_owner()
    pr_branch <- branch
  }

  urls <- pr_find(source, github_repo(), github_owner(), pr_branch)

  if (length(urls) == 0) {
    NULL
  } else if (length(urls) == 1) {
    gert::git_config_set(config_url, urls[[1]], git_repo())
    urls[[1]]
  } else {
    ui_stop("Multiple PRs correspond to this branch. Please close before continuing")
  }
}

pr_find <- function(owner,
                    repo,
                    pr_owner = owner,
                    pr_branch = git_branch()) {
  prs <- gh::gh("GET /repos/:owner/:repo/pulls",
    owner = owner,
    repo = repo,
    .limit = Inf,
    .token = check_github_token(allow_empty = TRUE)
  )

  if (length(prs) < 1) {
    return(character())
  }

  refs <- purrr::map_chr(prs, c("head", "ref"), .default = NA_character_)
  user <- purrr::map_chr(prs, c("head", "user", "login"), .default = NA_character_)
  urls <- purrr::map_chr(prs, c("html_url"), .default = NA_character_)

  urls[refs == pr_branch & user == pr_owner]
}

check_pr_readiness <- function() {
  cfg <- classify_github_setup()
  if (cfg$unsupported) {
    stop_bad_github_config(cfg)
  }
  if (cfg$type %in% c("ours", "fork")) {
    return(invisible())
  }
  if (!(cfg$type %in% c("theirs", "fork_no_upstream"))) {
    ui_stop("Internal error. Unexpected GitHub config type: {cfg$type}")
  }
  stop_unsupported_pr_config(cfg)
}

# use this right before creating a new PR or right after stopping work on a PR
# (temporarily or for good)
# usually, we'll be on `master` (or, in future, the default branch) and the goal
# is to make sure we're up-to-date with the primary repo
pr_pull_from_primary <- function() {
  in_a_fork <- nrow(github_remotes2("upstream", github_get = FALSE)) > 0
  # TODO: generalize to default branch
  if (in_a_fork && git_branch() == "master") {
    git_pull(remref = "upstream/master")
  } else {
    # pull from upstream tracking branch
    git_pull()
  }
}
