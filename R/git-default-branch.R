#' Infer default Git branch
#'
#' @description

#' Figure out the default branch of the current Git repo, preferably from local
#' information, but possibly from the `HEAD` ref of the `upstream` or `origin`
#' remote. Since "default branch" is not a well-defined Git concept, certain
#' assumptions are baked into this function:

#' * The local Git repo accurately reflects the branch conventions of the
#' overall project, either by definition (because you control the project) or
#' because you're keeping up-to-date with the source repository.

#' * Typical default branch names are `main`, `master`, and `default`, which we
#' look for in that order.

#' * The remote names `origin` and `upstream` are used in the conventional
#' manner.

#'
#' If you want to discover and adapt to a branch move, such as a switch from
#' `master` to `main`, see [use_git_default_branch()] instead. That function
#' also helps you make such a switch in a project you control.
#' `git_default_branch()` is a passive function that takes things at face value,
#' whereas [use_git_default_branch()] makes an active effort to discover or
#' enact or change.
#'
#' @return A branch name
#' @export
#'
#' @examples
#' \dontrun{
#' git_default_branch()
#' }
git_default_branch <- function() {
  repo <- git_repo()

  gb <- gert::git_branch_list(local = TRUE, repo = repo)[["name"]]
  if (length(gb) == 1) {
    return(gb)
  }

  # Check the usual suspects re: default branch
  gb <- set_names(gb)
  usual_suspects_branchname <- c("main", "master", "default")
  branch_candidates <- purrr::discard(gb[usual_suspects_branchname], is.na)

  if (length(branch_candidates) == 1) {
    return(branch_candidates[[1]])
  }
  # either 0 or >=2 of the usual suspects are present

  # Can we learn what HEAD points to on a relevant Git remote?
  gr <- git_remotes()
  usual_suspects_remote <- c("upstream", "origin")
  gr <- purrr::compact(gr[usual_suspects_remote])

  if (length(gr)) {
    remote_names <- set_names(names(gr))

    # check symbolic ref, e.g. refs/remotes/origin/HEAD (a local operation)
    remote_heads <- map(
      remote_names,
      ~ gert::git_remote_info(.x, repo = repo)$head
    )
    remote_heads <- purrr::compact(remote_heads)
    if (length(remote_heads)) {
      return(path_file(remote_heads[[1]]))
    }

    # ask the remote (a remote operation)
    remote_heads <- map(remote_names, git_default_branch_remote)
    remote_heads <- purrr::compact(remote_heads)
    if (length(remote_heads)) {
      return(path_file(remote_heads[[1]]))
    }

  }
  # no luck consulting usual suspects re: Git remotes
  # go back to locally configured branches

  # Is init.defaultBranch configured?
  # https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch
  init_default_branch <- git_cfg_get("init.defaultBranch")
  if ((!is.null(init_default_branch)) && (init_default_branch %in% gb)) {
    return(init_default_branch)
  }

  # take first existing branch from usual suspects
  if (length(branch_candidates)) {
    return(branch_candidates[[1]])
  }

  # take first existing branch
  if (length(gb)) {
    return(gb[[1]])
  }

  # I think this means we are on an unborn branch
  ui_stop("
    Can't determine the default branch for this repo
    Do you need to make your first commit?")
}

#' @section `git_branch_default()`:
#' Please call [git_default_branch()] instead. In hindsight, that is a better
#' name for this function.
#' @export
#' @rdname usethis-defunct
git_branch_default <- function() {
  lifecycle::deprecate_soft("2.1.0", "git_branch_default()", "git_default_branch()")
  git_default_branch()
}

#' Change (or discover a change in) the default Git branch
#'
#' @description

#' While Git itself has no official concept of "default branch", in reality,
#' practically all Git repos and users have an **effective default branch**.
#' Historically this was usually `master`, but `main` is an increasingly popular
#' choice and this branch renaming requires some local and remote work.
#'
#' `use_git_default_branch()` facilitates several proactive steps around the
#' default branch:

#' * `use_git_default_branch(scope = "user", new_name = "main")` configures
#'   `init.defaultBranch` at the global (a.k.a user) level. This only affects
#'   new local Git repos you create in the future.
#' * `use_git_default_branch(scope = "project")` discovers the default branch
#'   from the remote source repo for the current Git repo / project. If that
#'   appears to have changed, e.g. from `master` to `main`, we do the necessary
#'   branch renaming in your local repo and, if relevant, in your fork.
#' * `use_git_default_branch(scope = "project", old_name = "master", new_name = "main")`
#'   moves the local `master` branch to `main`, updates the remote source repo,
#'   and, if relevant, also updates your fork. This only works for a repo that
#'   you administer.
#'

#' @inheritParams edit
#' @param old_name Name of the **local** branch that is currently functioning as
#'   the default branch. If unspecified, this can often be inferred.
#' @param new_name New name of the default branch. The presence of this argument
#'   determines whether we are actively changing the project's default branch or
#'   discovering whether such a change has been made in the project.
#'
#' @return The new default branch name.
#' @export
#'
#' @examples
#' \dontrun{
#' use_git_default_branch(scope = "user", new_name = "main")
#'
#' use_git_default_branch(scope = "project")
#'
#' use_git_default_branch(scope = "project", old_name = "master", new_name = "main")
#' }
use_git_default_branch <- function(scope = c("project", "user"),
                                   old_name = NULL,
                                   new_name = NULL) {
  scope <- arg_match(scope)
  switch(
    scope,
    project = use_git_default_branch_project(old_name, new_name),
    user    = use_git_default_branch_user(new_name)
  )
}

use_git_default_branch_user <- function(new_name = NULL) {
  new_name <- new_name %||% "main"
  check_string(new_name)
  ui_done("Configuring {ui_field('init.defaultBranch')} as {ui_value(new_name)}.")
  gert::git_config_global_set("init.defaultBranch", new_name)
}

use_git_default_branch_project <- function(old_name = NULL, new_name = NULL) {
  if (is.null(new_name)) {
    rediscover_default_branch(old_name)
  } else {
    rename_default_branch(old_name, new_name)
  }
}

# `verbose = FALSE` exists only so we can call this at the end of
# rename_default_branch() and suppress some of the redundant messages
rediscover_default_branch <- function(old_name = NULL, verbose = TRUE) {
  ui_done("Rediscovering the default branch from source repo.")
  maybe_string(old_name)

  # GitHub's official TODOs re: manually updating local environments
  # after a source repo renames the default branch:

  # git branch -m OLD-BRANCH-NAME NEW-BRANCH-NAME
  # git fetch origin
  # git branch -u origin/NEW-BRANCH-NAME NEW-BRANCH-NAME
  # git remote set-head origin -a

  # Note: they are assuming the relevant repo is known as origin, but it could
  # just as easily be, e.g., upstream.

  repo <- git_repo()
  if (!is.null(old_name) &&
      !gert::git_branch_exists(old_name, local = TRUE, repo = repo)) {
    ui_stop("Can't find existing local branch named {ui_value(old_name)}")
  }

  cfg <- github_remote_config(github_get = TRUE)
  check_for_config(cfg, ok_configs = c("ours", "fork", "theirs"))
  if (verbose) {
    ui_info("GitHub remote configuration type: {ui_value(cfg$type)}")
    ui_info("
      Read more about GitHub remote configurations at:
      {ui_value('https://happygitwithr.com/common-remote-setups.html')}")
  }

  tr <- target_repo(cfg, role = "source", ask = FALSE)
  db <- tr$default_branch
  ui_info("
    Source repo is {ui_value(tr$repo_spec)} and its current default branch is \\
    {ui_value(db)}.")
  # goal, in Git-speak: git remote set-head <remote> -a
  # goal, for humans: learn and record the default branch (i.e. the target of
  # the symbolic-ref refs/remotes/<remote>/HEAD) for the named remote
  # https://git-scm.com/docs/git-remote#Documentation/git-remote.txt-emset-headem
  # for very stale repos, a fetch is a necessary pre-requisite
  # I provide `refspec = db` to avoid fetching all refs, which can be VERY slow
  # for a repo like ggplot2 (several minutes, with no progress reporting)
  # however this means I can't do `prune = TRUE` to prune, e.g. origin/master
  gert::git_fetch(remote = tr$name, refspec = db, verbose = FALSE, repo = repo)
  gert::git_remote_ls(remote = tr$name, verbose = FALSE, repo = repo)

  old_name <- old_name %||% guess_local_default_branch()

  if (old_name == db) {
    ui_info("Local branch named {ui_value(db)} already exists.")
  } else {
    # goal, in Git-speak: git branch -m <old_name> <db>
    ui_done("Moving local {ui_value(old_name)} branch to {ui_value(db)}.")
    gert::git_branch_move(branch = old_name, new_branch = db, repo = repo)
    rstudio_git_tickle()
  }

  # goal, in Git-speak: git branch -u <remote>/<db> <db>
  source_remref <- glue("{tr$name}/{db}")
  ui_done("
    Setting remote tracking branch for local {ui_value(db)} \\
    branch to {ui_value(source_remref)}.")
  gert::git_branch_set_upstream(
    branch = db,
    upstream = source_remref,
    repo = repo
  )

  # for "ours" and "theirs", the source repo is the only remote on our radar and
  # we're done ingesting the default branch from the source repo
  # but for "fork", we also need to update
  #   the fork = the user's primary repo = the remote known as origin
  if (cfg$type == "fork" && old_name != db) {
    gh <- gh_tr(cfg$origin)
    ui_done("
      Renaming {ui_value(old_name)} branch to {ui_value(db)} in your \\
      fork {ui_value(cfg$origin$repo_spec)}.")
    gh(
      "POST /repos/{owner}/{repo}/branches/{from}/rename",
      from = old_name,
      new_name = db
    )
    # giving refspec has same pros and cons as noted above for source repo
    gert::git_fetch(remote = "origin", refspec = db, verbose = FALSE, repo = repo)
    gert::git_remote_ls(remote = "origin", verbose = FALSE, repo = repo)
  }

  invisible(db)
}

rename_default_branch <- function(old_name = NULL, new_name = NULL) {
  ui_done('
    Renaming (a.k.a. "moving") the default branch for {ui_value(project_name())}.')
  repo <- git_repo()
  maybe_string(old_name)
  check_string(new_name)

  # if (!is.null(old_name) &&
  #     !gert::git_branch_exists(old_name, local = TRUE, repo = repo)) {
  #   ui_stop("Can't find existing local branch named {ui_value(old_name)}")
  # }

  cfg <- github_remote_config(github_get = TRUE)
  check_for_config(cfg, ok_configs = c("ours", "fork", "no_github"))
  ui_info("GitHub remote configuration type: {ui_value(cfg$type)}")
  ui_info("
    Read more about GitHub remote configurations at:
    {ui_value('https://happygitwithr.com/common-remote-setups.html')}")

  # TODO: handle no_github case and exit
  # cfg is now either fork or ours

  tr <- target_repo(cfg, role = "source", ask = FALSE)
  old_source_db <- tr$default_branch
  ui_info("
    Source repo is {ui_value(tr$repo_spec)} and its current default branch is \\
    {ui_value(old_source_db)}.")

  if (!isTRUE(tr$can_admin)) {
    ui_stop("
      You don't seem to have {ui_field('admin')} permissions for \\
      {ui_value(tr$repo_spec)}, which is required to rename the default \\
      branch.")
  }

  old_name <- old_name %||% guess_local_default_branch()

  if (old_name != old_source_db) {
    ui_oops("
      It's weird that the current default branch for your local repo and \\
      the source repo are different:
      {ui_value(old_name)} (local) != {ui_value(old_source_db)} (source)")
    if (ui_nope(
      "Are you sure you want to proceed?",
      yes = "yes", no = "no", shuffle = FALSE)) {
      ui_stop("Cancelling.")
    }
  }

  if (new_name == old_source_db) {
    ui_info("
      Source repo {ui_value(tr$repo_spec)} already has \\
      {ui_value(old_source_db)} as its default branch.")
  } else {
    gh <- gh_tr(tr)
    ui_done("
      Renaming {ui_value(old_source_db)} branch to {ui_value(new_name)} in \\
      the source repo {ui_value(tr$repo_spec)}.")
    gh(
      "POST /repos/{owner}/{repo}/branches/{from}/rename",
      from = old_source_db,
      new_name = new_name
    )
  }

  rediscover_default_branch(old_name = old_name, verbose = FALSE)
}

git_default_branch_remote <- function(remote = "origin") {
  url <- git_remotes()[[remote]]
  if (length(url) == 0) {
    ui_stop("There is no remote named {ui_value(remote)}.")
  }

  # TODO: generalize here for GHE hosts that don't include 'github'
  parsed <- parse_github_remotes(url)
  if (grepl("github", parsed$host)) {
    return(github_remotes(remote, github_get = TRUE)$default_branch)
  }

  repo <- git_repo()
  res <- tryCatch(
    {
      gert::git_fetch(remote = remote, repo = repo, verbose = FALSE)
      gert::git_remote_ls(remote = remote, verbose = FALSE, repo = repo)
    },
    error = function(e) NA_character_
  )
  if (is.data.frame(res)) {
    res <- path_file(res$symref[res$ref == "HEAD"])
  }
  res
}

guess_local_default_branch <- function(ask = is_interactive()) {
  repo <- git_repo()

  gb <- gert::git_branch_list(local = TRUE, repo = repo)[["name"]]
  if (length(gb) == 0) {
    ui_stop("
      Can't find any local branches.
      Do you need to make your first commit?")
  }

  if ("main" %in% gb && !"master" %in% gb) {
    propose <- "main"
  } else if ("master" %in% gb && !"main" %in% gb) {
    propose <- "master"
  } else if (length(gb) == 1) {
    propose <- gb
  } else {
    ui_stop("
      Not clear which existing local branch plays the role of the default.
      You'll need to specify {ui_code('old_name')} explicitly.")
  }

  if (!ask || !is_interactive()) {
    ui_done("
      Local branch {ui_value(propose)} appears to play the role of \\
      the default branch.")
    return(propose)
  }

  if (ui_yeah("
    The local branch {ui_value(propose)} appears to play the role of \\
    the default branch.
    Do you confirm?",
    yes = "yes", no = "no", shuffle = FALSE)) {
    propose
  } else {
    ui_stop("Cancelling. Local default branch is not clear.")
  }
}
