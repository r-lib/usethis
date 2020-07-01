#' Helpers for GitHub pull requests
#'
#' @description
#' The `pr_*` family of functions is designed to make working with GitHub pull
#' requests (PRs) as painless as possible for both contributors and package
#' maintainers. They are designed to support the Git and GitHub best practices
#' described in [Happy Git and GitHub for the useR](https://happygitwithr.com).
#'
#' To use the `pr_*` functions, your project must be a Git repo and have one of
#' these GitHub remote configurations:
#' * "ours": You can push to the GitHub remote configured as `origin`. It's not
#'   a fork. `origin` points to the **primary repo**.
#' * "fork": You can push to the GitHub remote configured as `origin`, it's a
#'   fork, and its parent is configured as `upstream`. `origin` points to your
#'   **personal** copy and upstream` points to the **primary repo**.
#'
#' "Ours" and "fork" are two of several GitHub remote configurations examined in
#' [Common remote setups](https://happygitwithr.com/common-remote-setups.html)
#' in Happy Git.
#'
#' The `pr_*` functions also use your Git/GitHub credentials to carry out
#' various remote operations. See below for more.
#'
#' @section Git/GitHub credentials:
#' The `pr_*` functions interact with GitHub both as a conventional Git remote
#' and via the REST API. Therefore, your credentials must be discoverable. Which
#' credentials do we mean?
#' * A GitHub personal access token (PAT) must be configured as the `GITHUB_PAT`
#'   environment variable. [create_github_token()] helps you do this. This PAT
#'   allows usethis to call the GitHub API on your behalf. If you use HTTPS
#'   remotes, the PAT is also used for Git operations, such as `git push`. That
#'   means the PAT is the only credential you need! This is why HTTPS + PAT is
#'   highly recommended for anyone new to Git and GitHub and PRs.
#' * If you use SSH remotes, your SSH keys must also be discoverable, in
#'   addition to your PAT. The public key must be added to your GitHub account.
#'
#' Usethis uses the gert package for Git operations
#' (<https://docs.ropensci.org/gert>) and gert, in turn, relies on the
#' credentials package (<https://docs.ropensci.org/credentials/>) for auth. If
#' you have credential problems, focus your troubleshooting on getting the
#' credentials package to find your credentials. Its introductory vignette is an
#' excellent place to learn more:
#' <https://cran.r-project.org/web/packages/credentials/vignettes/intro.html>.
#'
#' If the `pr_*` functions need to configure a new remote, its transport
#' protocol (HTTPS vs SSH) is determined by the protocol used for `origin`.
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
#' You can then run `pr_finish()` to delete your PR branch. In most cases,
#' however, the maintainer will ask you to make some changes. Make the changes,
#' then run `pr_push()` to update your PR.
#'
#' It's also possible that the maintainer will contribute some code to your PR:
#' to get those changes back onto your computer, run `pr_pull()`. It can also
#' happen that other changes have occurred in the package since you first
#' created your PR. You might need to merge the `master` (or default) branch
#' into your PR branch. Do that by running `pr_pull_upstream()`: this makes sure
#' that your PR is compatible with the primary repo's main line of development.
#' Both `pr_pull()` and `pr_pull_upstream()` can result in merge conflicts, so
#' be prepared to resolve before continuing.
#'
#' @section For maintainers:
#' To download a PR locally so that you can experiment with it, run
#' `pr_fetch(<pr_number>)`. If you make changes, run `pr_push()` to push them
#' back to GitHub. After you have merged the PR, run `pr_finish()` to delete the
#' local branch and remove the remote associated with the contributor's fork.
#'
#' @section Overview of all the functions:

#' * `pr_init()`: Does a preparatory pull from the primary repo, to get a good
#'   start point. Creates and checks out a new branch. Nothing is pushed to
#'   or created on GitHub. That only happens upon the first `pr_push()`.

#' * `pr_resume()`: Resume work on a PR by switching to its existing branch and
#'   pulling any updates from GitHub.

#' * `pr_fetch()`: Checks out a PR on the primary repo for local exploration.
#'   This can cause a new remote to be configured and a new local branch to be
#'   created. The local branch is configured to track its remote counterpart.
#'   `pr_fetch()` puts a maintainer in a position where they can push changes
#'   into an external PR via `pr_push()`.

#' * `pr_push()`: The first time it's called, a PR branch is pushed to `origin`
#'   and you're taken to a webpage where a new PR (or draft PR) can be created.
#'   This also sets up the local branch to track its remote counterpart.
#'   Subsequent calls to `pr_push()` make sure the local branch has all the
#'   remote changes and, if so, pushes local changes, thereby updating the PR.

#' * `pr_pull()`: Pulls changes from the local branch's remote tracking branch.
#'   If a maintainer has extended your PR, this is how you bring those changes
#'   back into your local work.

#' * `pr_pull_upstream()`: Pulls changes from the `master` branch of the primary
#'   repo into the current local branch. This can be used when the local branch
#'   is `master` or when it's a PR branch.

#' * `pr_sync()` = `pr_pull() + pr_pull_upstream() + pr_push()`. In words, grab
#'   any remote changes in the PR and merge then into your local work. Then
#'   merge in any changes from `master` of the primary repo. Finally, push the
#'   result of all this back into the PR.

#' * `pr_pause()`: Makes sure you're up-to-date with any remote changes in the
#'   PR. Then switches back to `master` and pulls from the primary repo.

#' * `pr_view()`: Visits the PR associated with a branch in the browser. usethis
#'   records this URL in git config of the local repo.

#' * `pr_finish()`: If `number` is given, first does `pr_fetch(number)`. It's
#'   assumed the current branch is the PR branch of interest. First, makes sure
#'   there are no unpushed local changes. Switches back to `master` and pulls
#'   changes from the primary repo. Deletes the PR branch. If the PR came from
#'   an external fork, the corresponding remote is deleted, provided it's not in
#'   use by any other local branches.
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

  if (git_branch_exists(branch, local = TRUE)) {
    code <- glue("pr_resume(\"{branch}\")")
    ui_info("
      Branch {ui_value(branch)} already exists, calling {ui_code(code)}")
    return(pr_resume(branch))
  }

  # TODO: get the github config here? so I can consult below?
  check_pr_readiness()
  # TODO(@jennybc): if no internet, could offer option to proceed anyway
  # error shows git2r but we'll get similar error with gert
  # Error in git2r::fetch(repo, name = remref_remote(remref), refspec = branch,  :
  # Error in 'git2r_remote_fetch': failed to resolve address for github.com: nodename nor servname provided, or not known

  # TODO: honor default branch
  if (git_branch() != "master") {
    if (ui_nope("Create local PR branch with non-master parent?")) {
      return(invisible(FALSE))
    }
  }

  check_no_uncommitted_changes(untracked = TRUE)
  pr_pull_primary_override()

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
  if (!git_branch_exists(branch, local = TRUE)) {
    code <- glue("pr_init(\"{branch}\")")
    ui_stop("
      No branch named {ui_value(branch)} exists.
      Call {ui_code(code)} to create a new PR branch.")
  }

  check_pr_readiness()
  # TODO: turn off the interactive choice here? If there are uncommitted
  # changes, I think the branch switch will always fail.
  # OTOH, there's no harm in letting that happen, i.e. no risk here of
  # doing something partially.
  check_no_uncommitted_changes(untracked = TRUE)

  ui_done("Switching to branch {ui_value(branch)}")
  git_branch_switch(branch)
  git_pull()

  ui_todo("Use {ui_code('pr_push()')} to create or update PR.")
  invisible()
}

#' @export
#' @rdname pull-requests
#' @param number Number of PR to fetch.
#'
#' @examples
#' \dontrun{
#' pr_fetch(123)
#' }
pr_fetch <- function(number) {
  cfg <- classify_github_setup()
  check_pr_readiness(cfg)
  check_no_uncommitted_changes()

  # GET the PR ----
  owner <- switch(
    cfg$type,
    ours = cfg$origin$repo_owner,
    fork = cfg$upstream$repo_owner
  )
  repo_name <- cfg$origin$repo_name
  auth_token <- check_github_token(allow_empty = TRUE)
  pr <- gh::gh(
    "GET /repos/:owner/:repo/pulls/:number",
    owner = owner,
    repo = repo_name,
    number = number,
    .token = auth_token
  )
  pr_string <- glue("{owner}/{repo_name}/#{number}")
  pr_user <- glue("@{pr$user$login}")
  ui_done("
    Checking out PR {ui_value(pr_string)} ({ui_field(pr_user)}): \\
    {ui_value(pr$title)}")

  # Figure out remote, remote branch, local branch ----
  pr_branch_theirs <- pr$head$ref
  if (pr$head$repo$fork) { # PR is from a fork
    pr_remote <- spec_owner(pr$head$repo$full_name)
    pr_branch_ours <- sub(":", "-", pr$head$label)
  } else {                 # PR is from a branch in the primary repo
    pr_remote <- switch(cfg$type, ours = "origin", fork = "upstream")
    pr_branch_ours <- pr_branch_theirs
  }
  if (!isTRUE(pr$maintainer_can_modify)) {
    ui_info("
      Note that user does NOT allow maintainer to modify this PR \\
      at this time,
      although this can be changed.")
  }
  pr_remref <- glue("{pr_remote}/{pr_branch_theirs}")

  repo <- git_repo()

  # Add PR remote, if necessary ----
  if (!pr_remote %in% names(git_remotes())) {
    protocol <- github_remote_protocol()
    url <- with(pr$head$repo, switch(protocol, https = clone_url, ssh = ssh_url))
    if (is.null(url)) {
      ui_stop("
        Can't get URL for repo where PR originates.
        Perhaps it has been deleted?")
    }

    ui_done("Adding remote {ui_value(pr_remote)} as {ui_value(url)}")
    gert::git_remote_add(pr_remote, url, repo = repo)
    config_key <- glue("remote.{pr_remote}.created-by")
    gert::git_config_set(config_key, "usethis::pr_fetch", repo = repo)
  }

  gert::git_fetch(
    remote = remref_remote(pr_remref),
    refspec = remref_branch(pr_remref),
    repo = repo,
    verbose = FALSE
  )

  # Create local branch, if necessary, and switch to it ----
  if (!git_branch_exists(pr_branch_ours, local = TRUE)) {
    ui_done("Creating and switching to local branch {ui_value(pr_branch_ours)}")
    ui_done("Setting {ui_value(pr_remref)} as remote tracking branch")
    git_branch_create_and_switch(pr_branch_ours, pr_remref)
    config_key <- glue("branch.{pr_branch_ours}.created-by")
    gert::git_config_set(config_key, "usethis::pr_fetch", repo = repo)
    config_url <- glue("branch.{pr_branch_ours}.pr-url")
    gert::git_config_set(config_url, pr$html_url, repo = repo)
    return(invisible())
  }

  # Local branch pre-existed; make sure tracking branch is set, switch, & pull
  ui_done("Switching to branch {ui_value(pr_branch_ours)}")
  git_branch_switch(pr_branch_ours)
  config_url <- glue("branch.{pr_branch_ours}.pr-url")
  gert::git_config_set(config_url, pr$html_url, git_repo())

  pr_branch_ours_tracking <- git_branch_tracking(pr_branch_ours)
  if (is.na(pr_branch_ours_tracking) ||
      pr_branch_ours_tracking != pr_remref) {
    ui_done("Setting {ui_value(pr_remref)} as remote tracking branch")
    gert::git_branch_set_upstream(pr_remref, repo = repo)
  }
  git_pull()
}

#' @export
#' @rdname pull-requests
pr_push <- function() {
  check_pr_readiness()
  check_branch_not_master()
  check_no_uncommitted_changes()

  branch <- git_branch()
  remote_tracking_branch <- git_branch_tracking(branch)
  if (!is.na(remote_tracking_branch)) {
    check_branch_pulled(use = "pr_pull()")
  }

  if (is.na(remote_tracking_branch)) {
    remote_tracking_branch <- NULL
  }
  git_push(remref = remote_tracking_branch)

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

  git_pull()

  invisible(TRUE)
}

#' @export
#' @rdname pull-requests
pr_pull_upstream <- function() {
  check_pr_readiness()
  check_no_uncommitted_changes()

  # TODO: honor default branch
  branch <- "master"
  remote <- spec_owner(get_primary_spec())
  remref <- glue("{remote}/{branch}")

  ui_done("Pulling in changes from the primary repo {ui_value(remref)}")
  git_pull(remref)
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
  # TODO: honor default branch
  git_branch_switch("master")
  pr_pull_primary_override()
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

  branch <- git_branch()

  tracking_branch <- git_branch_tracking(branch)
  has_remote_branch <- !is.na(tracking_branch)
  if (has_remote_branch) {
    check_branch_pushed(use = "pr_push()")
  }

  # TODO: honor default branch
  ui_done("Switching back to {ui_value('master')} branch")
  git_branch_switch("master")
  pr_pull_primary_override()

  ui_done("Deleting local {ui_value(branch)} branch")
  gert::git_branch_delete(branch, repo = repo)

  if (!has_remote_branch) {
    return(invisible())
  }

  remote <- remref_remote(tracking_branch)
  created_by <- git_cfg_get(glue("remote.{remote}.created-by"))
  if (is.null(created_by) || !grepl("^usethis::pr_", created_by)) {
    return(invisible())
  }

  branches <- gert::git_branch_list(git_repo())
  branches <- branches[branches$local & !is.na(branches$upstream), ]
  if (sum(grepl(glue("^refs/remotes/{remote}"), branches$upstream)) == 0) {
    ui_done("Removing remote {ui_value(remote)}")
    gert::git_remote_remove(remote, repo = repo)
  }
}

pr_create_gh <- function() {
  # TODO: need a lighterweight way to learn ours vs fork here
  cfg <- classify_github_setup()
  owner <- switch(
    cfg$type,
    ours = cfg$origin$repo_owner,
    fork = cfg$upstream$repo_owner
  )
  repo <- cfg$origin$repo_name
  branch <- git_branch()

  ui_done("Create PR at link given below")
  view_url(glue("https://github.com/{owner}/{repo}/compare/{branch}"))
}

pr_url <- function(branch = git_branch()) {
  # Have we done this before? Check if we've cached pr-url in git config.
  config_url <- glue("branch.{branch}.pr-url")
  url <- git_cfg_get(config_url, where = "local")
  if (!is.null(url)) {
    return(url)
  }

  primary_owner <- spec_owner(get_primary_spec())
  pr_branch <- remref_branch(git_branch_tracking(branch))

  if (is.na(pr_branch)) {
    return()
  }

  urls <- pr_find(primary_owner, github_repo(), github_owner(), pr_branch)

  if (length(urls) == 0) {
    NULL
  } else if (length(urls) == 1) {
    gert::git_config_set(config_url, urls[[1]], repo = git_repo())
    urls[[1]]
  } else {
    ui_stop("
      Multiple PRs correspond to this branch. Please close before continuing")
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

  refs <- map_chr(prs, c("head", "ref"), .default = NA_character_)
  user <- map_chr(prs, c("head", "user", "login"), .default = NA_character_)
  urls <- map_chr(prs, c("html_url"), .default = NA_character_)

  urls[refs == pr_branch & user == pr_owner]
}

check_pr_readiness <- function(cfg = NULL) {
  cfg <- cfg %||% classify_github_setup()
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

# Make sure to pull from upstream/master (as opposed to origin/master) if we're
# in master branch of a fork. I wish everyone set up master to track the master
# branch in the primary repo, but this protects us against sub-optimal setup.
pr_pull_primary_override <- function() {
  in_a_fork <- nrow(github_remotes2("upstream", github_get = FALSE)) > 0
  # TODO: generalize to default branch
  if (in_a_fork && git_branch() == "master") {
    remref <- "upstream/master"
  } else {
    remref <- NULL
  }
  git_pull()
}
