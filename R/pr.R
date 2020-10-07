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
#' * "ours": You can push to the GitHub remote configured as `origin` and it's
#'   not a fork.
#' * "fork": You can push to the GitHub remote configured as `origin`, it's a
#'   fork, and its parent is configured as `upstream`. `origin` points to your
#'   **personal** copy and `upstream` points to the **source repo**.
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
#' * A GitHub personal access token (PAT) must be discoverable by the gh
#'   package, which is used for GitHub operations via the REST API. See
#'   [create_github_token()] for more about getting and configuring a PAT.
#' * If you use the HTTPS protocol for Git remotes, your PAT is also used for
#'   Git operations, such as `git push`. Usethis uses the gert package for this,
#'   so the PAT must be discoverable by gert. Generally gert and gh will
#'   discover and use the same PAT. This ability to "kill two birds with one
#'   stone" is why HTTPS + PAT is our recommended auth strategy for those new
#'   to Git and GitHub and PRs.
#' * If you use SSH remotes, your SSH keys must also be discoverable, in
#'   addition to your PAT. The public key must be added to your GitHub account.
#'
#' If the `pr_*` functions need to configure a new remote, its transport
#' protocol (HTTPS vs SSH) is determined by the protocol used for `origin`.
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
#' and pulling any changes from its upstream tracking branch, if it has one.

#' * `pr_fetch()`: Checks out a PR on the source repo for local exploration.
#' This can cause a new remote to be configured and a new local branch to be
#' created. The local branch is configured to track its remote counterpart.
#' `pr_fetch()` puts a maintainer in a position where they can push changes into
#' an external PR via `pr_push()`.

#' * `pr_push()`: The first time it's called, a PR branch is pushed to `origin`
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

#' * `pr_sync()` = `pr_pull() + pr_merge_main() + pr_push()`. In words, grab any
#' remote changes in the PR and merge then into your local work. Then merge in
#' any changes from the default branch of the primary repo. Finally, push the
#' result of all this back into the PR.

#' * `pr_pause()`: Makes sure you're up-to-date with any remote changes in the
#' PR. Then switches back to the default branch (usually named `main` or
#' `master`) and pulls from the source repo.

#' * `pr_view()`: Visits the PR associated with the current branch in the
#' browser (default) or the specific PR identified by `number`.
#' (FYI [browse_github_pulls()] is a handy way to visit the list of all PRs for
#' the current project.)

#' * `pr_finish()`: If `number` is given, first does `pr_fetch(number)`. It's
#' assumed the current branch is the PR branch of interest. First, makes sure
#' there are no unpushed local changes. Switches back to the default branch and
#' pulls changes from the source repo. If the PR has been merged and user has
#' permission, deletes the remote branch. Deletes the PR branch. If the PR came
#' from an external fork, the corresponding remote is deleted, provided it's not
#' in use by any other local branches.
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

  cfg <- github_remote_config()
  good_configs <- c("ours", "theirs", "fork")
  maybe_good_configs <- c("maybe_ours_or_theirs", "maybe_fork")
  if (!cfg$type %in% c(good_configs, maybe_good_configs)) {
    stop_unsupported_pr_config(cfg)
  }

  if (cfg$type %in% maybe_good_configs) {
    ui_line('
      Unable to confirm the GitHub remote configuration is "pull request ready"
      This probably means you need to configure a personal access token
      {ui_code("create_github_token()")} can help with that
      (Or maybe we\'re just offline?)')
    if (ui_github_remote_config_wat(cfg)) {
      ui_stop("Aborting")
    }
  }

  challenge_non_default_branch(
    "Are you sure you want to create a PR branch based on a non-default branch?"
  )

  current_branch <- git_branch()
  if (!is.na(git_branch_tracking(current_branch))) {
    comparison <- git_branch_compare(current_branch)
    if (comparison$remote_only > 0) {
      check_no_uncommitted_changes(untracked = TRUE)
    }
  }
  pr_pull_source_override()

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
    dat <- branches_with_no_upstream_or_github_upstream()
    choice <- utils::menu(
      title = glue("Which branch do you want to checkout? (0 to exit)"),
      choices = glue("{format(dat$name, justify = 'right')} --> {dat$pr_pretty}")
    )
    branch <- dat$name[choice]
  }
  stopifnot(is_string(branch))

  repo <- git_repo()
  if (!gert::git_branch_exists(branch, local = TRUE, repo = repo)) {
    code <- glue("pr_init(\"{branch}\")")
    ui_stop("
      No branch named {ui_value(branch)} exists.
      Call {ui_code(code)} to create a new PR branch.")
  }

  check_no_uncommitted_changes(untracked = TRUE)

  ui_done("Switching to branch {ui_value(branch)}")
  gert::git_branch_checkout(branch, repo = repo)
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
pr_fetch <- function(number = NULL) {
  cfg <- github_remote_config()
  check_pr_readiness(cfg)
  check_no_uncommitted_changes()

  if (is.null(number)) {
    ui_info("No PR specified ... looking up open PRs")
    pr_dat <- pr_list(cfg)
    pr_display <- pr_dat[c("pr_user", "pr_string", "pr_title")]
    pr_display$pr_user <- map(pr_display$pr_user, ~ glue("@{.x}"))
    pr_pretty <- purrr::pmap(
      pr_display,
      function(pr_string, pr_user, pr_title) {
        glue("
          {ui_value(pr_string)} ({ui_field(pr_user)}): {ui_value(pr_title)}")
      }
    )
    choice <- utils::menu(
      title = "Which PR do you want to checkout? (0 to exit)",
      choices = pr_pretty
    )
    if (choice == 0) {
      ui_stop("No PR selected, aborting")
    }
    pr <- pr_dat[choice, ]
  } else {
    pr <- pr_get(number = number, cfg = cfg)
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
    protocol <- cfg$origin$protocol
    url <- switch(protocol, https = pr$pr_https_url, ssh = pr$pr_ssh_url)
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
  cfg <- github_remote_config()
  check_pr_readiness(cfg)
  check_pr_branch()
  check_no_uncommitted_changes()

  repo <- git_repo()
  branch <- git_branch()
  remref <- git_branch_tracking(branch)
  if (is.na(remref)) {
    ui_done("Pushing local {ui_value(branch)} branch")
    gert::git_push(verbose = FALSE, repo = repo)
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

  # Prompt to create PR on first push
  pr <- pr_find(branch, cfg = cfg)
  if (is.null(pr)) {
    pr_create_gh()
  } else {
    ui_done("
      View PR at {ui_value(pr$pr_html_url)} or call {ui_code('pr_view()')}")
  }

  invisible()
}

#' @export
#' @rdname pull-requests
pr_pull <- function() {
  check_pr_readiness()
  check_pr_branch()
  check_no_uncommitted_changes()

  git_pull()

  invisible(TRUE)
}

#' @export
#' @rdname pull-requests
pr_merge_main <- function() {
  cfg <- github_remote_config()
  check_pr_readiness(cfg)
  check_no_uncommitted_changes()

  remote <- switch(cfg$type, ours = "origin", fork = "upstream")
  remref <- glue("{remote}/{git_branch_default()}")

  ui_done("
    Pulling in changes from default branch of the source repo \\
    {ui_value(remref)}")
  git_pull(remref, verbose = FALSE)
}

#' @export
#' @rdname pull-requests
pr_sync <- function() {
  check_pr_readiness()

  branch <- git_branch()
  tracking_branch <- git_branch_tracking(branch)
  if (is.na(tracking_branch)) {
    ui_stop("
      Branch {ui_value(branch)} has no remote tracking branch to sync with.
      Do you need to call {ui_code('pr_push()')} for the first time?")
  }

  pr_pull()
  pr_merge_main()
  pr_push()
}

#' @export
#' @rdname pull-requests
pr_view <- function(number = NULL) {
  cfg <- github_remote_config()

  if(is.null(number)) {
    check_pr_branch()
    url <- pr_url(cfg = cfg)
    if (is.null(url)) {
      ui_stop("
        Current branch ({ui_value(git_branch())}) does not appear to be \\
        connected to a PR
        Do you need to call {ui_code('pr_push()')} for the first time?")
    }
  } else {
    pr <- pr_get(number = number, cfg = cfg)
    url <- pr$pr_html_url
  }
  view_url(url)
}

#' @export
#' @rdname pull-requests
pr_pause <- function() {
  default_branch <- git_branch_default()
  if (git_branch() == default_branch) {
    ui_info("
      Already on this repo's default branch ({ui_value(default_branch)})
      Nothing to do")
    return(invisible())
  }
  check_pr_readiness()
  check_pr_branch()
  check_no_uncommitted_changes()
  check_branch_pulled(use = "pr_pull()")

  ui_done("Switching back to default branch ({ui_value(default_branch)})")
  gert::git_branch_checkout(default_branch, repo = git_repo())
  pr_pull_source_override()
}

#' @export
#' @rdname pull-requests
pr_finish <- function(number = NULL) {
  cfg <- github_remote_config()
  check_pr_readiness(cfg)
  repo <- git_repo()

  if (!is.null(number)) {
    pr_fetch(number)
  }

  check_pr_branch()
  check_no_uncommitted_changes()

  branch <- git_branch()

  tracking_branch <- git_branch_tracking(branch)
  has_remote_branch <- !is.na(tracking_branch)
  if (has_remote_branch) {
    check_branch_pushed(use = "pr_push()")
  }

  default_branch <- git_branch_default()
  ui_done("Switching back to default branch ({ui_value(default_branch)})")
  gert::git_branch_checkout(default_branch, repo = repo)
  pr_pull_source_override()

  if (!has_remote_branch) {
    ui_done("Deleting local {ui_value(branch)} branch")
    gert::git_branch_delete(branch, repo = repo)
    return(invisible())
  }

  remote <- remref_remote(tracking_branch)
  # delete remote branch, if have permission and PR is merged
  if (remote == "origin") {
    if (is.null(number)) {
      number <- sub("^.+pull/", "", pr_url(branch, cfg = cfg))
    }
    if (length(number)) {
      pr <- pr_get(number = number, cfg = cfg)
      if (!is.na(pr$pr_merged_at)) {
        ui_done("
          PR {ui_value(pr$pr_string)} has been merged, \\
          deleting remote branch {ui_value(tracking_branch)}")
        gert::git_push(
          remote = "origin",
          refspec = glue(":refs/heads/{remref_branch(tracking_branch)}"),
          verbose = FALSE
        )
      } else {
        ui_done("
          PR {ui_value(pr$pr_string)} is unmerged, \\
          remote branch {ui_value(tracking_branch)} remains")
      }
    }
  }

  ui_done("Deleting local {ui_value(branch)} branch")
  gert::git_branch_delete(branch, repo = repo)

  # delete remote, if we added it AND no remaining tracking branches
  created_by <- git_cfg_get(glue("remote.{remote}.created-by"))
  if (is.null(created_by) || !grepl("^usethis::pr_", created_by)) {
    return(invisible())
  }

  branches <- gert::git_branch_list(git_repo())
  branches <- branches[branches$local & !is.na(branches$upstream), ]
  if (sum(grepl(glue("^refs/remotes/{remote}"), branches$upstream)) == 0) {
    ui_done("Removing remote {ui_value(remote)}")
    gert::git_remote_remove(remote = remote, repo = repo)
  }
}

pr_create_gh <- function() {
  origin <-  github_remote_list("origin")
  branch <- git_branch()
  ui_done("Create PR at link given below")
  view_url(glue("https://github.com/{origin$repo_spec}/compare/{branch}"))
}

pr_find <- function(branch = git_branch(), cfg = NULL) {
  # Have we done this before? Check if we've cached pr-url in git config.
  config_url <- glue("branch.{branch}.pr-url")
  url <- git_cfg_get(config_url, where = "local")
  if (!is.null(url)) {
    return(pr_get(sub("^.+pull/", "", url)))
  }

  pr_dat <- pr_list(cfg = cfg)
  m <- match(branch, pr_dat$pr_local_branch)
  if (!is.na(m)) {
    url <- pr_dat$pr_html_url[[m]]
    gert::git_config_set(config_url, url, repo = git_repo())
    return(as.list(pr_dat[m, ]))
  }

  NULL
}

pr_url <- function(branch = git_branch(), cfg = NULL) {
  pr <- pr_find(branch, cfg = cfg)
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
  gbl <- gert::git_branch_list(repo = git_repo())
  gbl <- gbl[gbl$local & !is.na(gbl$upstream), c("name", "upstream")]
  gbl$upstream <- sub("^refs/remotes/", "", gbl$upstream)
  m <- match(pr_remref, gbl$upstream)
  out$pr_local_branch <- if (is.na(m)) NA else gbl$name[m]

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

pr_list <- function(cfg = NULL) {
  tr <- target_repo(cfg = cfg, ask = FALSE)
  prs <- gh::gh(
    "GET /repos/:owner/:repo/pulls",
    owner = tr$repo_owner, repo = tr$repo_name,
    .limit = Inf,
    .api_url = tr$api_url
  )
  out <- map(prs, pr_data_tidy)
  out <- map(out, ~ as.data.frame(.x, stringsAsFactors = FALSE))
  do.call(rbind, out)
}

pr_get <- function(number, cfg = NULL) {
  tr <- target_repo(cfg = cfg, ask = FALSE)
  raw <- gh::gh(
    "GET /repos/:owner/:repo/pulls/:number",
    owner = tr$repo_owner, repo = tr$repo_name,
    number = number,
    .token = tr$token, .api_url = tr$api_url
  )
  pr_data_tidy(raw)
}

check_pr_readiness <- function(cfg = NULL) {
  cfg <- cfg %||% github_remote_config()
  if (isTRUE(cfg$pr_ready)) {
    return(invisible(cfg))
  }
  stop_unsupported_pr_config(cfg)
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

# Make sure to pull from upstream/DEFAULT (as opposed to origin/DEFAULT) if
# we're in DEFAULT branch of a fork. I wish everyone set up DEFAULT to track the
# DEFAULT branch in the source repo, but this protects us against sub-optimal
# setup.
pr_pull_source_override <- function() {
  tr <- target_repo(ask = FALSE)
  default_branch <- git_branch_default()
  if (tr$remote == "upstream" && git_branch() == default_branch) {
    remref <- glue("upstream/{default_branch}")
  } else {
    remref <- NULL
  }
  git_pull(remref = remref, verbose = FALSE)
}

branches_with_no_upstream_or_github_upstream <- function(cfg = NULL) {
  repo <- git_repo()
  gb_dat <- gert::git_branch_list(repo = repo)
  gb_dat <- gb_dat[
    gb_dat$local & gb_dat$name != git_branch_default(),
    c("name", "upstream")
  ]
  gb_dat$remref   <- sub("^refs/remotes/", "", gb_dat$upstream)
  gb_dat$upstream <- NULL
  gb_dat$remote   <- remref_remote(gb_dat$remref)
  gb_dat$ref      <- remref_branch(gb_dat$remref)

  ghr <- github_remote_list(these = NULL)[["remote"]]
  gb_dat <- gb_dat[is.na(gb_dat$remref) | (gb_dat$remote %in% ghr), ]
  gb_dat$timestamp <- map_chr(
    gb_dat$name, ~ format(gert::git_log(.x, max = 1, repo = repo)$time)
  )

  pr_dat <- pr_list(cfg = cfg)
  dat <- merge(
    x    = gb_dat, y    = pr_dat,
    by.x = "name", by.y = "pr_local_branch",
    all.x = TRUE
  )

  dat <- dat[order(dat$pr_number, dat$pr_updated_at, dat$timestamp, decreasing = TRUE), ]
  dat$pr_pretty <- ifelse(
    is.na(dat$pr_string),
    "<no PR>",
    glue("{dat$pr_string} (@{dat$pr_user}): {dat$pr_title}")
  )

  dat
}
