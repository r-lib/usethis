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
  check_uses_git()
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
#' @param old_name Old name of the default branch. If unspecified, this can
#'   often be inferred.
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
  if (!is_string(new_name)) {
    ui_stop("{ui_code('new_name')} must be a single string.")
  }
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

rediscover_default_branch <- function(old_name = NULL) {
  if (!is.null(old_name) && !is_string(old_name)) {
    ui_stop("{ui_code('old_name')} must be a single string.")
  }

  ui_info("We're going to rediscover default branch from source repo.")
}

rename_default_branch <- function(old_name = NULL, new_name = NULL) {
  if (!is.null(old_name) && !is_string(old_name)) {
    ui_stop("{ui_code('old_name')} must be a single string.")
  }
  if (!is.null(new_name) && !is_string(new_name)) {
    ui_stop("{ui_code('new_name')} must be a single string.")
  }

  ui_info("We're going to rename the default branch.")
}

git_default_branch_remote <- function(remote = "origin") {
  url <- git_remotes()[[remote]]
  if (length(url) == 0) {
    ui_stop("No remote named {ui_value(remote)} is configured.")
  }

  # TODO: generalize here for GHE hosts that don't include 'github'
  parsed <- parse_github_remotes(url)
  if (grepl("github", parsed$host)) {
    return(github_remotes(remote, github_get = TRUE)$default_branch)
  }

  repo <- git_repo()
  res <- tryCatch(
    {
      gert::git_fetch(
        remote = remote,
        prune = TRUE,
        repo = repo,
        verbose = FALSE
      )
      gert::git_remote_ls(remote = remote, verbose = FALSE, repo = repo)
    },
    error = function(e) NA_character_
  )
  if (is.data.frame(res)) {
    res <- path_file(res$symref[res$ref == "HEAD"])
  }
  res
}
