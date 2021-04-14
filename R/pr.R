#' Helpers for GitHub pull requests
#'
#' @description
#' The `pr_*` family of functions is designed to make working with GitHub pull
#' requests (PRs) as painless as possible for both contributors and package
#' maintainers.
#'
#' To use the `pr_*` functions, your project must be a Git repo and have one of
#' these GitHub remote configurations:
#' * "ours": You can push to the GitHub remote configured as `origin` and it's
#'   not a fork.
#' * "fork": You can push to the GitHub remote configured as `origin`, it's a
#'   fork, and its parent is configured as `upstream`. `origin` points to your
#'   **personal** copy and `upstream` points to the **source repo**.
#'
#' "Ours" and "fork" are two of several GitHub remote configurations examined in
#' [Common remote setups](https://happygitwithr.com/common-remote-setups.html)
#' in Happy Git and GitHub for the useR.
#'
#' The [Pull Request
#' Helpers](https://usethis.r-lib.org/articles/articles/pr-functions.html)
#' article walks through the process of making a pull request with the `pr_*`
#' functions.
#'
#' The `pr_*` functions also use your Git/GitHub credentials to carry out
#' various remote operations. See below for more.
#'
#' @template double-auth
#'
#' @section For contributors:
#' To contribute to a package, first use `create_from_github("OWNER/REPO")` to
#' fork the source repository, and then check out a local copy.
#'
#' Next use `pr_init()` to create a branch for your PR. It is best practice to
#' never make commits to the default branch branch of a fork (usually named
#' `main` or `master`), because you do not own it. A pull request should always
#' come from a feature branch. It will be much easier to pull upstream changes
#' from the fork parent if you only allow yourself to work in feature branches.
#' It is also much easier for a maintainer to explore and extend your PR if you
#' create a feature branch.
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
#' created your PR. You might need to merge the default branch (usually named
#' `main` or `master`) into your PR branch. Do that by running
#' `pr_merge_main()`: this makes sure that your PR is compatible with the
#' primary repo's main line of development. Both `pr_pull()` and
#' `pr_merge_main()` can result in merge conflicts, so be prepared to resolve
#' before continuing.
#'
#' @section For maintainers:
#' To download a PR locally so that you can experiment with it, run
#' `pr_fetch()` and select the PR or, if you already know its number, call
#' `pr_fetch(<pr_number>)`. If you make changes, run `pr_push()` to push them
#' back to GitHub. After you have merged the PR, run `pr_finish()` to delete the
#' local branch and remove the remote associated with the contributor's fork.
#'
#' @section Overview of all the functions:

#' * `pr_init()`: Does a preparatory pull of the default branch from the source
#' repo, to get a good start point. Creates and checks out a new branch. Nothing
#' is pushed to or created on GitHub (that does not happen until the first time
#' you call `pr_push()`).

#' * `pr_resume()`: Resume work on a PR by switching to an existing local branch
#' and pulling any changes from its upstream tracking branch, if it has one. If
#' called with no arguments, up to 9 local branches are offered for interactive
#' selection, with a preference for branches connected to PRs and for branches
#' with recent activity.

#' * `pr_fetch()`: Checks out a PR on the source repo for local exploration. If
#' called with no arguments, up to 9 open PRs are offered for interactive
#' selection. This can cause a new remote to be configured and a new local
#' branch to be created. The local branch is configured to track its remote
#' counterpart. The transport protocol (HTTPS vs SSH) for any new remote is
#' inherited from the remote representing the source repo. `pr_fetch()` puts a
#' maintainer in a position where they can push changes into an internal or
#' external PR via `pr_push()`.

#' * `pr_push()`: The first time it's called, a PR branch is pushed to GitHub
#' and you're taken to a webpage where a new PR (or draft PR) can be created.
#' This also sets up the local branch to track its remote counterpart.
#' Subsequent calls to `pr_push()` make sure the local branch has all the remote
#' changes and, if so, pushes local changes, thereby updating the PR.

#' * `pr_pull()`: Pulls changes from the local branch's remote tracking branch.
#' If a maintainer has extended your PR, this is how you bring those changes
#' back into your local work.

#' * `pr_merge_main()`: Pulls changes from the default branch of the source repo
#' into the current local branch. This can be used when the local branch is the
#' default branch or when it's a PR branch.

#' * `pr_pause()`: Makes sure you're up-to-date with any remote changes in the
#' PR. Then switches back to the default branch (usually named `main` or
#' `master`) and pulls from the source repo.

#' * `pr_view()`: Visits the PR associated with the current branch in the
#' browser (default) or the specific PR identified by `number`.
#' (FYI [browse_github_pulls()] is a handy way to visit the list of all PRs for
#' the current project.)

#' * `pr_forget()`: Does local clean up when the current branch is an actual or
#' notional PR that you want to abandon. Maybe you initiated it yourself, via
#' `pr_init()`, or you used `pr_fetch()` to explore a PR from GitHub. Only does
#' *local* operations: does not update or delete any remote branches, nor does
#' it close any PRs. Alerts the user to any uncommitted or unpushed work that is
#' at risk of being lost. If user chooses to proceed, switches back to the
#' default branch, pulls changes from source repo, and deletes local PR branch.
#' Any associated Git remote is deleted, if the "forgotten" PR was the only
#' branch using it.

#' * `pr_finish()`: Does post-PR clean up, but does NOT actually merge or close
#' a PR (maintainer should do this in the browser). If `number` is not given,
#' infers the PR from the upstream tracking branch of the current branch. If
#' `number` is given, it does not matter whether the PR exists locally. If PR
#' exists locally, alerts the user to uncommitted or unpushed changes, then
#' switches back to the default branch, pulls changes from source repo, and
#' deletes local PR branch. If the PR came from an external fork, any associated
#' Git remote is deleted, provided it's not in use by any other local branches.
#' If the PR has been merged and user has permission, deletes the remote branch
#' (this is the only remote operation that `pr_finish()` potentially does).
#'
#' @name pull-requests
NULL

#' @export
#' @rdname pull-requests
#' @param branch Name of a new or existing local branch. If creating a new
#'   branch, note this should usually consist of lower case letters, numbers,
#'   and `-`.
pr_init <- function(branch) {
  stopifnot(is_string(branch))
  repo <- git_repo()

  if (gert::git_branch_exists(branch, local = TRUE, repo = repo)) {
    code <- glue("pr_resume(\"{branch}\")")
    ui_info("
      Branch {ui_value(branch)} already exists, calling {ui_code(code)}")
    return(pr_resume(branch))
  }

  # don't absolutely require PAT success, because we could be offline
  # or in another salvageable situation, e.g. need to configure PAT
  cfg <- github_remote_config(github_get = NA)
  check_for_bad_config(cfg)
  tr <- target_repo(cfg, ask = FALSE)

  maybe_good_configs <- c("maybe_ours_or_theirs", "maybe_fork")
  if (cfg$type %in% maybe_good_configs) {
    ui_line('
      Unable to confirm the GitHub remote configuration is "pull request ready"
      You probably need to configure a personal access token for \\
      {ui_value(tr$host)}
      See {ui_code("gh_token_help()")} for help
      (Or maybe we\'re just offline?)')
    if (ui_github_remote_config_wat(cfg)) {
      ui_stop("Aborting")
    }
  }

  challenge_non_default_branch(
    "Are you sure you want to create a PR branch based on a non-default branch?"
  )

  online <- is_online(tr$host)
  if (online) {
    # this is not pr_pull_source_override() because:
    # a) we may NOT be on default branch (although we probably are)
    # b) we didn't just switch to the branch we're on, therefore we have to
    #    consider that the pull may be affected by uncommitted changes or a
    #    merge
    current_branch <- git_branch()
    default_branch <- git_branch_default()
    if (current_branch == default_branch) {
      # override for mis-configured forks, that have default branch tracking
      # the fork (origin) instead of the source (upstream)
      remref <- glue("{tr$remote}/{default_branch}")
    } else {
      remref <- git_branch_tracking(current_branch)
    }
    if (!is.na(remref)) {
      comparison <- git_branch_compare(current_branch, remref)
      if (comparison$remote_only > 0) {
        challenge_uncommitted_changes(untracked = TRUE)
      }
      ui_done("Pulling changes from {ui_value(remref)}")
      git_pull(remref = remref, verbose = FALSE)
    }
  } else {
    ui_info("
      Unable to pull changes for current branch, since we are offline")
  }

  ui_done("Creating and switching to local branch {ui_value(branch)}")
  gert::git_branch_create(branch, repo = repo)
  config_key <- glue("branch.{branch}.created-by")
  gert::git_config_set(config_key, value = "usethis::pr_init", repo = repo)

  ui_todo("Use {ui_code('pr_push()')} to create PR.")
  invisible()
}

#' @export
#' @rdname pull-requests
pr_resume <- function(branch = NULL) {
  if (is.null(branch)) {
    ui_info("
      No branch specified ... looking up local branches and associated PRs")
    branch <- choose_branch()
    if (is.null(branch)) {
      ui_oops("Repo doesn't seem to have any non-default branches")
      return(invisible())
    }
    if (length(branch) == 0) {
      ui_oops("No branch selected, exiting")
      return(invisible())
    }
  }
  stopifnot(is_string(branch))

  repo <- git_repo()
  if (!gert::git_branch_exists(branch, local = TRUE, repo = repo)) {
    code <- glue("pr_init(\"{branch}\")")
    ui_stop("
      No branch named {ui_value(branch)} exists
      Call {ui_code(code)} to create a new PR branch")
  }

  challenge_uncommitted_changes(untracked = TRUE)

  ui_done("Switching to branch {ui_value(branch)}")
  gert::git_branch_checkout(branch, repo = repo)
  git_pull()

  ui_todo("Use {ui_code('pr_push()')} to create or update PR.")
  invisible()
}

#' @export
#' @rdname pull-requests
#' @param number Number of PR.
#' @param target Which repo to target? This is only a question in the case of a
#'   fork. In a fork, there is some slim chance that you want to consider pull
#'   requests against your fork (the primary repo, i.e. `origin`) instead of
#'   those against the source repo (i.e. `upstream`, which is the default).
#'
#' @examples
#' \dontrun{
#' pr_fetch(123)
#' }
pr_fetch <- function(number = NULL, target = c("source", "primary")) {
  tr <- target_repo(github_get = NA, role = target, ask = FALSE)
  challenge_uncommitted_changes()

  if (is.null(number)) {
    ui_info("No PR specified ... looking up open PRs")
    pr <- choose_pr(tr = tr)
    if (is.null(pr)) {
      ui_oops("No open PRs found for {ui_value(tr$repo_spec)}")
      return(invisible())
    }
    if (min(lengths(pr)) == 0) {
      ui_oops("No PR selected, exiting")
      return(invisible())
    }
  } else {
    pr <- pr_get(number = number, tr = tr)
  }

  if (is.na(pr$pr_repo_owner)) {
    ui_stop("The repo where PR {number} originates seems to have been deleted")
  }

  pr_user <- glue("@{pr$pr_user}")
  ui_done("
    Checking out PR {ui_value(pr$pr_string)} ({ui_field(pr_user)}): \\
    {ui_value(pr$pr_title)}")

  if (pr$pr_from_fork && isFALSE(pr$maintainer_can_modify)) {
    ui_info("
      Note that user does NOT allow maintainer to modify this PR at this \\
      time, although this can be changed.")
  }

  repo <- git_repo()

  remote <- github_remote_list(pr$pr_remote)
  if (nrow(remote) == 0) {
    url <- switch(tr$protocol, https = pr$pr_https_url, ssh = pr$pr_ssh_url)
    ui_done("Adding remote {ui_value(pr$pr_remote)} as {ui_value(url)}")
    gert::git_remote_add(url = url, name = pr$pr_remote, repo = repo)
    config_key <- glue("remote.{pr$pr_remote}.created-by")
    gert::git_config_set(config_key, "usethis::pr_fetch", repo = repo)
  }
  pr_remref <- glue_data(pr, "{pr_remote}/{pr_ref}")
  gert::git_fetch(
    remote = pr$pr_remote,
    refspec = pr$pr_ref,
    repo = repo,
    verbose = FALSE
  )

  if (is.na(pr$pr_local_branch)) {
    pr$pr_local_branch <-
      if (pr$pr_from_fork) sub(":", "-", pr$pr_label) else pr$pr_ref
  }

  # Create local branch, if necessary, and switch to it ----
  if (!gert::git_branch_exists(pr$pr_local_branch, local = TRUE, repo = repo)) {
    ui_done("
      Creating and switching to local branch {ui_value(pr$pr_local_branch)}")
    ui_done("Setting {ui_value(pr_remref)} as remote tracking branch")
    gert::git_branch_create(pr$pr_local_branch, ref = pr_remref, repo = repo)
    config_key <- glue("branch.{pr$pr_local_branch}.created-by")
    gert::git_config_set(config_key, "usethis::pr_fetch", repo = repo)
    config_url <- glue("branch.{pr$pr_local_branch}.pr-url")
    gert::git_config_set(config_url, pr$pr_html_url, repo = repo)
    return(invisible())
  }

  # Local branch pre-existed; make sure tracking branch is set, switch, & pull
  ui_done("Switching to branch {ui_value(pr$pr_local_branch)}")
  gert::git_branch_checkout(pr$pr_local_branch, repo = repo)
  config_url <- glue("branch.{pr$pr_local_branch}.pr-url")
  gert::git_config_set(config_url, pr$pr_html_url, repo = repo)

  pr_branch_ours_tracking <- git_branch_tracking(pr$pr_local_branch)
  if (is.na(pr_branch_ours_tracking) ||
      pr_branch_ours_tracking != pr_remref) {
    ui_done("Setting {ui_value(pr_remref)} as remote tracking branch")
    gert::git_branch_set_upstream(pr_remref, repo = repo)
  }
  git_pull(verbose = FALSE)
}

#' @export
#' @rdname pull-requests
pr_push <- function() {
  cfg <- github_remote_config(github_get = TRUE)
  check_ours_or_fork(cfg)
  check_pr_branch()
  challenge_uncommitted_changes()

  repo <- git_repo()
  branch <- git_branch()
  remref <- git_branch_tracking(branch)
  if (is.na(remref)) {
    # this is the first push
    if (cfg$type == "fork" && cfg$upstream$can_push && is_interactive()) {
      choices <- c(
        origin   = glue(
          "{cfg$origin$repo_spec} = {ui_value('origin')} (external PR)"),
        upstream = glue(
          "{cfg$upstream$repo_spec} = {ui_value('upstream')} (internal PR)")
      )
      title <- glue("Which repo do you want to push to?")
      choice <- utils::menu(choices, graphics = FALSE, title = title)
      remote <-  names(choices)[[choice]]
    } else {
      remote <- "origin"
    }
    ui_done("
      Pushing local {ui_value(branch)} branch to {ui_value(remote)} remote")
    gert::git_push(remote = remote, verbose = FALSE, repo = repo)
  } else {
    check_branch_pulled(use = "pr_pull()")
    ui_done("Pushing local {ui_value(branch)} branch to {ui_value(remref)}")
    gert::git_push(
      remote = remref_remote(remref),
      refspec = glue("refs/heads/{branch}:refs/heads/{remref_branch(remref)}"),
      verbose = FALSE,
      repo = repo
    )
  }

  # Prompt to create PR if does not exist yet
  tr <- target_repo(cfg, ask = FALSE)
  pr <- pr_find(branch, tr = tr)
  if (is.null(pr)) {
    pr_create()
  } else {
    ui_todo("
      View PR at {ui_value(pr$pr_html_url)} or call {ui_code('pr_view()')}")
  }

  invisible()
}

#' @export
#' @rdname pull-requests
pr_pull <- function() {
  check_ours_or_fork()
  check_pr_branch()
  challenge_uncommitted_changes()

  git_pull()

  invisible(TRUE)
}

#' @export
#' @rdname pull-requests
pr_merge_main <- function() {
  tr <- target_repo(github_get = TRUE, ask = FALSE)
  challenge_uncommitted_changes()
  remref <- glue("{tr$remote}/{git_branch_default()}")
  ui_done("
    Pulling changes from {ui_value(remref)} (default branch of source repo)")
  git_pull(remref, verbose = FALSE)
}

#' @export
#' @rdname pull-requests
pr_view <- function(number = NULL, target = c("source", "primary")) {
  tr <- target_repo(github_get = NA, role = target, ask = FALSE)
  url <- NULL
  if (is.null(number)) {
    branch <- git_branch()
    default_branch <- git_branch_default()
    if (branch != default_branch) {
      url <- pr_url(tr = tr)
      if (is.null(url)) {
        ui_info("
          Current branch ({ui_value(branch)}) does not appear to be \\
          connected to a PR")
      } else {
        number <- sub("^.+pull/", "", url)
        ui_info("
          Current branch ({ui_value(branch)}) is connected to PR #{number}")
      }
    }
  } else {
    pr <- pr_get(number = number, tr = tr)
    url <- pr$pr_html_url
  }
  if (is.null(url)) {
    ui_info("No PR specified ... looking up open PRs")
    pr <- choose_pr(tr = tr)
    if (is.null(pr)) {
      ui_oops("No open PRs found for {ui_value(tr$repo_spec)}")
      return(invisible())
    }
    if (min(lengths(pr)) == 0) {
      ui_oops("No PR selected, exiting")
      return(invisible())
    }
    url <- pr$pr_html_url
  }
  view_url(url)
}

#' @export
#' @rdname pull-requests
pr_pause <- function() {
  # intentionally naive selection of target repo
  tr <- target_repo(github_get = FALSE, ask = FALSE)

  default_branch <- git_branch_default()
  if (git_branch() == default_branch) {
    ui_info("
      Already on this repo's default branch ({ui_value(default_branch)})
      Nothing to do")
    return(invisible())
  }
  challenge_uncommitted_changes()
  # TODO: what happens here if offline?
  check_branch_pulled(use = "pr_pull()")

  ui_done("Switching back to default branch ({ui_value(default_branch)})")
  gert::git_branch_checkout(default_branch, repo = git_repo())
  pr_pull_source_override(tr = tr)
}

#' @export
#' @rdname pull-requests
pr_finish <- function(number = NULL, target = c("source", "primary")) {
  pr_clean(number = number, target = target, mode = "finish")
}

#' @export
#' @rdname pull-requests
pr_forget <- function() pr_clean(mode = "forget")

# unexported helpers ----

# Removes local evidence of PRs that you're done with or wish you'd never
# started or fetched
# Only possible remote action is to delete the remote branch for a merged PR
pr_clean <- function(number = NULL,
                     target = c("source", "primary"),
                     mode = c("finish", "forget")) {
  mode <- match.arg(mode)
  repo <- git_repo()
  tr <- target_repo(github_get = NA, role = target, ask = FALSE)

  if (is.null(number)) {
    check_pr_branch()
    pr <- pr_find(git_branch(), tr = tr, state = "all")
    # if the remote branch has already been deleted (probably post-merge), we
    # can't always reverse engineer what the corresponding local branch was, but
    # we already know it -- it's how we found the PR in the first place!
    if (!is.null(pr)) {
      pr$pr_local_branch <- pr$pr_local_branch %|% git_branch()
    }
  } else {
    pr <- pr_get(number = number, tr = tr)
  }

  pr_local_branch <- if (is.null(pr)) git_branch() else pr$pr_local_branch

  if (!is.na(pr_local_branch)) {
    if (pr_local_branch == git_branch()) {
      challenge_uncommitted_changes()
    }
    tracking_branch <- git_branch_tracking(pr_local_branch)
    if (is.na(tracking_branch)) {
      if (ui_nope("
        Local branch {ui_value(pr_local_branch)} has no associated remote \\
        branch.
        If we delete {ui_value(pr_local_branch)}, any work that exists only \\
        on this branch work may be hard for you to recover.
        Proceed anyway?")) {
        ui_stop("Aborting.")
      }
    } else {
      cmp <- git_branch_compare(
        branch = pr_local_branch,
        remref = tracking_branch
      )
      if (cmp$local_only > 0 && ui_nope("
          Local branch {ui_value(pr_local_branch)} has 1 or more commits \\
          that have not been pushed to {ui_value(tracking_branch)}.
          If we delete {ui_value(pr_local_branch)}, this work may be hard \\
          for you to recover.
          Proceed anyway?")) {
        ui_stop("Aborting.")
      }
    }
  }

  default_branch <- git_branch_default()
  if (git_branch() != default_branch) {
    ui_done("Switching back to default branch ({ui_value(default_branch)})")
    gert::git_branch_checkout(default_branch, force = TRUE, repo = repo)
    pr_pull_source_override(tr = tr)
  }

  if (!is.na(pr_local_branch)) {
    ui_done("Deleting local {ui_value(pr_local_branch)} branch")
    gert::git_branch_delete(pr_local_branch, repo = repo)
  }

  if (is.null(pr)) {
    return(invisible())
  }

  pr_branch_delete(pr)

  # delete remote, if we added it AND no remaining tracking branches
  created_by <- git_cfg_get(glue("remote.{pr$pr_remote}.created-by"))
  if (is.null(created_by) || !grepl("^usethis::pr_", created_by)) {
    return(invisible())
  }

  branches <- gert::git_branch_list(local = TRUE, repo = repo)
  branches <- branches[!is.na(branches$upstream), ]
  if (sum(grepl(glue("^refs/remotes/{pr$pr_remote}"), branches$upstream)) == 0) {
   ui_done("Removing remote {ui_value(pr$pr_remote)}")
    gert::git_remote_remove(remote = pr$pr_remote, repo = repo)
  }
  invisible()
}

# Make sure to pull from upstream/DEFAULT (as opposed to origin/DEFAULT) if
# we're in DEFAULT branch of a fork. I wish everyone set up DEFAULT to track the
# DEFAULT branch in the source repo, but this protects us against sub-optimal
# setup.
pr_pull_source_override <- function(tr = NULL) {
  # naive selection of target repo; calling function should analyse the config
  tr <- tr %||% target_repo(github_get = FALSE, ask = FALSE)
  current_branch <- git_branch()
  default_branch <- git_branch_default()
  if (current_branch != default_branch) {
    ui_stop("
      Internal error: pr_pull_source_override() should only be used when on \\
      default branch")
  }
  # override for mis-configured forks, that have default branch tracking
  # the fork (origin) instead of the source (upstream)
  remref <- glue("{tr$remote}/{default_branch}")
  if (is_online(tr$host)) {
    ui_done("Pulling changes from {ui_value(remref)}")
    git_pull(remref = remref, verbose = FALSE)
  } else {
    ui_info("
      Can't reach {ui_value(tr$host)}, therefore unable to pull changes from \\
      {ui_value(remref)}")
  }
}

pr_create <- function() {
  branch <- git_branch()
  tracking_branch <- git_branch_tracking(branch)
  remote <- remref_remote(tracking_branch)
  remote_dat <- github_remotes(remote, github_get = FALSE)
  ui_todo("Create PR at link given below")
  view_url(glue_data(remote_dat, "{host_url}/{repo_spec}/compare/{branch}"))
}

# retrieves 1 PR, if we can establish a tracking relationship between
# `branch` and a PR branch
pr_find <- function(branch = git_branch(),
                    tr = NULL,
                    state = c("open", "closed", "all")) {
  # Have we done this before? Check if we've cached pr-url in git config.
  config_url <- glue("branch.{branch}.pr-url")
  url <- git_cfg_get(config_url, where = "local")
  if (!is.null(url)) {
    return(pr_get(number = sub("^.+pull/", "", url), tr = tr))
  }

  tracking_branch <- git_branch_tracking(branch)
  if (is.na(tracking_branch)) {
    return(NULL)
  }

  state <- match.arg(state)
  remote <- remref_remote(tracking_branch)
  remote_dat <- github_remotes(remote)
  pr_dat <- pr_list(
    tr = tr,
    state = state,
    head = glue("{remote_dat$repo_owner}:{remref_branch(tracking_branch)}")
  )
  if (nrow(pr_dat) == 0) {
    return(NULL)
  }
  if (nrow(pr_dat) > 1) {
    ui_stop("
      Branch {ui_value(branch)} is associated with multiple PRs: \\
      {ui_value(paste0('#', pr_dat$pr_number))}")
  }
  gert::git_config_set(config_url, pr_dat$pr_html_url, repo = git_repo())
  as.list(pr_dat)
}

pr_url <- function(branch = git_branch(),
                   tr = NULL,
                   state = c("open", "closed", "all")) {
  state <- match.arg(state)
  pr <- pr_find(branch, tr = tr, state = state)
  if (is.null(pr)) {
    NULL
  } else {
    pr$pr_html_url
  }
}

pr_data_tidy <- function(pr) {
  out <- list(
    pr_number     = pluck_int(pr, "number"),
    pr_title      = pluck_chr(pr, "title"),
    pr_user       = pluck_chr(pr, "user", "login"),
    pr_created_at = pluck_chr(pr, "created_at"),
    pr_updated_at = pluck_chr(pr, "updated_at"),
    pr_merged_at  = pluck_chr(pr, "merged_at"),
    pr_label      = pluck_chr(pr, "head", "label"),
    # the 'repo' element of 'head' is NULL when fork has been deleted
    pr_repo_owner = pluck_chr(pr, "head", "repo", "owner", "login"),
    pr_ref        = pluck_chr(pr, "head", "ref"),
    pr_repo_spec  = pluck_chr(pr, "head", "repo", "full_name"),
    pr_from_fork  = pluck_lgl(pr, "head", "repo", "fork"),
    # 'maintainer_can_modify' is only present when we GET one specific PR
    pr_maintainer_can_modify = pluck_lgl(pr, "maintainer_can_modify"),
    pr_https_url  = pluck_chr(pr, "head", "repo", "clone_url"),
    pr_ssh_url    = pluck_chr(pr, "head", "repo", "ssh_url"),
    pr_html_url   = pluck_chr(pr, "html_url"),
    pr_string     = glue("
      {pluck_chr(pr, 'base', 'repo', 'full_name')}/#{pluck_int(pr, 'number')}")
  )

  grl <- github_remote_list(these = NULL)
  m <- match(out$pr_repo_spec, grl$repo_spec)
  out$pr_remote <- if (is.na(m)) out$pr_repo_owner else grl$remote[m]

  pr_remref <- glue("{out$pr_remote}/{out$pr_ref}")
  gbl <- gert::git_branch_list(local = TRUE, repo = git_repo())
  gbl <- gbl[!is.na(gbl$upstream), c("name", "upstream")]
  gbl$upstream <- sub("^refs/remotes/", "", gbl$upstream)
  m <- match(pr_remref, gbl$upstream)
  out$pr_local_branch <- if (is.na(m)) NA_character_ else gbl$name[m]

  # If the fork has been deleted, these are all NA
  # - Because pr$head$repo is NULL:
  #   pr_repo_owner, pr_repo_spec, pr_from_fork, pr_https_url, pr_ssh_url
  # - Because derived from those above:
  #   pr_remote, pr_remref pr_local_branch
  # I suppose one could already have a local branch, if you fetched the PR
  # beforethe fork got deleted.
  # But an initial pr_fetch() won't work if the fork has been deleted.
  # I'm willing to accept that the pr_*() functions don't necessarily address
  # the "deleted fork" scenario. It's relatively rare.
  # example: https://github.com/r-lib/httr/pull/634

  out
}

pr_list <- function(tr = NULL,
                    github_get = NA,
                    state = c("open", "closed", "all"),
                    head = NULL) {
  tr <- tr %||% target_repo(github_get = github_get, ask = FALSE)
  state <- match.arg(state)
  gh <- gh_tr(tr)
  safely_gh <- purrr::safely(gh, otherwise = NULL)
  out <- safely_gh(
    "GET /repos/{owner}/{repo}/pulls",
    state = state, head = head, .limit = Inf
  )
  if (!is.null(out$error)) {
    ui_oops("Unable to retrieve PRs for {ui_value(tr$repo_spec)}")
    prs <- NULL
  } else {
    prs <- out$result
  }
  no_prs <- length(prs) == 0
  if (no_prs) {
    prs <- list(list())
  }
  out <- map(prs, pr_data_tidy)
  out <- map(out, ~ as.data.frame(.x, stringsAsFactors = FALSE))
  out <- do.call(rbind, out)
  if (no_prs) {
    out[0, ]
  } else {
    out
  }
}

# retrieves specific PR by number
pr_get <- function(number, tr = NULL, github_get = NA) {
  tr <- tr %||% target_repo(github_get = github_get, ask = FALSE)
  gh <- gh_tr(tr)
  raw <- gh("GET /repos/{owner}/{repo}/pulls/{number}", number = number)
  pr_data_tidy(raw)
}

check_pr_branch <- function() {
  default_branch <- git_branch_default()
  if (git_branch() != default_branch) {
    return(invisible())
  }
  ui_stop("
    The {ui_code('pr_*()')} functions facilitate pull requests.
    The current branch ({ui_value(default_branch)}) is this repo's default \\
    branch, but pull requests should NOT come from the default branch.
    Do you need to call {ui_code('pr_init()')} (new PR)?
    Or {ui_code('pr_resume()')} or {ui_code('pr_fetch()')} (existing PR)?")
}

branches_with_no_upstream_or_github_upstream <- function(tr = NULL) {
  repo <- git_repo()
  gb_dat <- gert::git_branch_list(local = TRUE, repo = repo)
  gb_dat <- gb_dat[
    gb_dat$name != git_branch_default(),
    c("name", "upstream", "updated")
  ]
  gb_dat$remref   <- sub("^refs/remotes/", "", gb_dat$upstream)
  gb_dat$upstream <- NULL
  gb_dat$remote   <- remref_remote(gb_dat$remref)
  gb_dat$ref      <- remref_branch(gb_dat$remref)

  ghr <- github_remote_list(these = NULL)[["remote"]]
  gb_dat <- gb_dat[is.na(gb_dat$remref) | (gb_dat$remote %in% ghr), ]

  pr_dat <- pr_list(tr = tr)
  dat <- merge(
    x    = gb_dat, y    = pr_dat,
    by.x = "name", by.y = "pr_local_branch",
    all.x = TRUE
  )
  dat <- dat[order(dat$pr_number, dat$pr_updated_at, dat$updated, decreasing = TRUE), ]

  dat
}

choose_branch <- function() {
  if (!is_interactive()) {
    return(character())
  }
  dat <- branches_with_no_upstream_or_github_upstream()
  if (nrow(dat) == 0) {
    return()
  }
  prompt <- "Which branch do you want to checkout? (0 to exit)"
  if (nrow(dat) > 9) {
    branches_not_shown <- utils::tail(dat$name, -9)
    n <- length(branches_not_shown)
    dat <- dat[1:9, ]
    pre <- glue("{n} branch{if (n > 1) 'es' else ''} not listed: ")
    listing <- glue_collapse(
      branches_not_shown, sep = ", ", width = getOption("width") - nchar(pre)
    )
    prompt <- glue("
      {prompt}
      {pre}{listing}")
  }
  dat$pretty_user <- map(dat$pr_user, ~ glue("@{.x}"))
  dat$pretty_name <- format(dat$name, justify = "right")
  dat_pretty <- purrr::pmap(
    dat[c("pretty_name", "pr_number", "pretty_user", "pr_title")],
    function(pretty_name, pr_number, pretty_user, pr_title) {
      if (is.na(pr_number)) {
        glue("{pretty_name}")
      } else {
        glue("{pretty_name} --> #{pr_number} ({ui_value(pretty_user)}): {pr_title}")
      }
    }
  )
  choice <- utils::menu(title = prompt, choices = dat_pretty)
  dat$name[choice]
}

choose_pr <- function(tr = NULL) {
  if (!is_interactive()) {
    return(list(pr_number = list()))
  }
  tr <- tr %||% target_repo()
  dat <- pr_list(tr)
  if (nrow(dat) == 0) {
    return()
  }
  # wording needs to make sense for pr_fetch() and pr_view()
  prompt <- "Which PR are you interested in? (0 to exit)"
  if (nrow(dat) > 9) {
    n <- nrow(dat) - 9
    dat <- dat[1:9, ]
    prompt <- glue("
      {prompt}
      {n} more {if (n > 1) 'PRs are' else 'PR is'} open; \\
      call {ui_code('browse_github_pulls()')} to browse all PRs")
  }
  pr_pretty <- purrr::pmap(
    dat[c("pr_string", "pr_user", "pr_title")],
    function(pr_string, pr_user, pr_title) {
      at_user <- glue("@{pr_user}")
      glue("
        {ui_value(pr_string)} ({ui_field(at_user)}): {ui_value(pr_title)}")
    }
  )
  choice <- utils::menu(title = prompt, choices = pr_pretty)
  as.list(dat[choice, ])
}

# deletes the remote branch associated with a PR
# returns invisible TRUE/FALSE re: whether a deletion actually occurred
# reasons this returns FALSE
# * don't have push permission on remote where PR branch lives
# * PR has not been merged
# * remote branch has already been deleted
pr_branch_delete <- function(pr) {
  remote <- pr$pr_remote
  remote_dat <- github_remotes(remote)
  if (!isTRUE(remote_dat$can_push)) {
    return(invisible(FALSE))
  }

  gh <- gh_tr(remote_dat)
  pr_ref <- tryCatch(
    gh(
      "GET /repos/{owner}/{repo}/git/ref/{ref}",
      ref = glue("heads/{pr$pr_ref}")
    ),
    http_error_404 = function(cnd) NULL
  )

  pr_remref <- glue_data(pr, "{pr_remote}/{pr_ref}")

  if (is.null(pr_ref)) {
    ui_info("
      PR {ui_value(pr$pr_string)} originated from branch \\
      {ui_value(pr_remref)}, which no longer exists")
    return(invisible(FALSE))
  }

  if (is.na(pr$pr_merged_at)) {
    ui_info("
      PR {ui_value(pr$pr_string)} is unmerged, \\
      we will not delete the remote branch {ui_value(pr_remref)}")
    return(invisible(FALSE))
  }

  ui_done("
    PR {ui_value(pr$pr_string)} has been merged, \\
    deleting remote branch {ui_value(pr_remref)}")
  # TODO: tryCatch here?
  gh(
    "DELETE /repos/{owner}/{repo}/git/refs/{ref}",
    ref = glue("heads/{pr$pr_ref}")
  )
  invisible(TRUE)
}
