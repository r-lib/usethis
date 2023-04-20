#' Get or set the default Git branch
#'
#' @description

#' The `git_default_branch*()` functions put some structure around the somewhat
#' fuzzy (but definitely real) concept of the default branch. In particular,
#' they support new conventions around the Git default branch name, globally or
#' in a specific project / Git repository.
#'
#' @section Background on the default branch:
#'

#' Technically, Git has no official concept of the default branch. But in
#' reality, almost all Git repos have an *effective default branch*. If there's
#' only one branch, this is it! It is the branch that most bug fixes and
#' features get merged in to. It is the branch you see when you first visit a
#' repo on a site such as GitHub. On a Git remote, it is the branch that `HEAD`
#' points to.
#'
#' Historically, `master` has been the most common name for the default branch,
#' but `main` is an increasingly popular choice.
#'

#' @section `git_default_branch_configure()`:

#' This configures `init.defaultBranch` at the global (a.k.a user) level. This
#' setting determines the name of the branch that gets created when you make the
#' first commit in a new Git repo. `init.defaultBranch` only affects the local
#' Git repos you create in the future.
#'

#' @section `git_default_branch()`:

#' This figures out the default branch of the current Git repo, integrating
#' information from the local repo and, if applicable, the `upstream` or
#' `origin` remote. If there is a local vs. remote mismatch,
#' `git_default_branch()` throws an error with advice to call
#' `git_default_branch_rediscover()` to repair the situation.
#'

#' For a remote repo, the default branch is the branch that `HEAD` points to.
#'

#' For the local repo, if there is only one branch, that must be the default!
#' Otherwise we try to identify the relevant local branch by looking for
#' specific branch names, in this order:
#' * whatever the default branch of `upstream` or `origin` is, if applicable
#' * `main`
#' * `master`
#' * the value of the Git option `init.defaultBranch`, with the usual deal where
#'   a local value, if present, takes precedence over a global (a.k.a.
#'   user-level) value
#'

#' @section `git_default_branch_rediscover()`:

#' This consults an external authority -- specifically, the remote **source
#' repo** on GitHub -- to learn the default branch of the current project /
#' repo. If that doesn't match the apparent local default branch (for example,
#' the project switched from `master` to `main`), we do the corresponding branch
#' renaming in your local repo and, if relevant, in your fork.

#'
#' See <https://happygitwithr.com/common-remote-setups.html> for more about
#' GitHub remote configurations and, e.g., what we mean by the source repo. This
#' function works for the configurations `"ours"`, `"fork"`, and `"theirs"`.

#' @section `git_default_branch_rename()`:

#' Note: this only works for a repo that you effectively own. In terms of
#' GitHub, you must own the **source repo** personally or, if
#' organization-owned, you must have `admin` permission on the **source repo**.
#'
#' This renames the default branch in the **source repo** on GitHub and then
#' calls `git_default_branch_rediscover()`, to make any necessary changes in the
#' local repo and, if relevant, in your personal fork.
#'
#' See <https://happygitwithr.com/common-remote-setups.html> for more about
#' GitHub remote configurations and, e.g., what we mean by the source repo. This
#' function works for the configurations `"ours"`, `"fork"`, and `"no_github"`.
#'
#' Regarding `"no_github"`: Of course, this function does what you expect for a
#' local repo with no GitHub remotes, but that is not the primary use case.

#' @return Name of the default branch.
#' @name git-default-branch
NULL

#' @export
#' @rdname git-default-branch
#' @examples
#' \dontrun{
#' git_default_branch()
#' }
git_default_branch <- function() {
  repo <- git_repo()

  # TODO: often when we call git_default_branch(), we already have a GitHub
  # configuration or target repo, as produced by github_remote_config() or
  # target_repo(). In that case, we don't need to start from scratch as we do
  # here. But I'm not sure it's worth adding complexity to allow passing this
  # data in.

  # TODO: this critique feels somewhat mis-placed, i.e. it brings up a general
  # concern about a repo's config (or the user's permissions and creds)
  # related to whether github_remotes() should be as silent as it is about
  # 404s
  critique_remote <- function(remote) {
    if (remote$is_configured && is.na(remote$default_branch)) {
      ui_oops("
        The {ui_value(remote$name)} remote is configured, but we can't \\
        determine its default branch.
        Possible reasons:
        - The remote repo no longer exists, suggesting the local remote should
          be deleted.
        - We are offline or that specific Git server is down.
        - You don't have the necessary permission or something is wrong with
          your credentials.")
    }
  }

  upstream <- git_default_branch_remote("upstream")
  if (is.na(upstream$default_branch)) {
    critique_remote(upstream)
    origin <- git_default_branch_remote("origin")
    if (is.na(origin$default_branch)) {
      critique_remote(origin)
      db_source <- list()
    } else {
      db_source <- origin
    }
  } else {
    db_source <- upstream
  }

  db_local_with_source <- tryCatch(
    guess_local_default_branch(db_source$default_branch),
    error = function(e) NA_character_
  )

  # these error sub-classes and error data are for the benefit of git_sitrep()

  if (is.na(db_local_with_source) ) {
    if (length(db_source)) {
      usethis_abort(c(
        "Default branch mismatch between local repo and remote.",
        "The default branch of the {.val {db_source$name}} remote is
        {.val {db_source$default_branch}}.",
        "But the local repo has no branch named
        {.val {db_source$default_branch}}.",
        "Call {.code git_default_branch_rediscover()} to resolve this."
        ),
        class = "error_default_branch",
        db_source = db_source
      )
    } else {
      usethis_abort(
        "Can't determine the local repo's default branch.",
        class = "error_default_branch"
      )
    }
  }
  # we learned a default branch from the local repo

  if (is.null(db_source$default_branch) ||
      is.na(db_source$default_branch) ||
      identical(db_local_with_source, db_source$default_branch)) {
    return(db_local_with_source)
  }
  # we learned a default branch from the source repo and it doesn't match
  # the local default branch

  usethis_abort(c(
    "Default branch mismatch between local repo and remote.",
    "The default branch of the {.val {db_source$name}} remote is
     {.val {db_source$default_branch}}.",
    "But the default branch of the local repo appears to be
     {.val {db_local_with_source}}.",
    "Call {.code git_default_branch_rediscover()} to resolve this."
    ),
    class = "error_default_branch",
    db_source = db_source, db_local = db_local_with_source
  )
}

# returns a whole data structure, because the caller needs the surrounding
# context to produce a helpful error message
git_default_branch_remote <- function(remote = "origin") {
  repo <- git_repo()
  out <- list(
    name = remote,
    is_configured = NA,
    url = NA_character_,
    repo_spec = NA_character_,
    default_branch = NA_character_
  )

  url <- git_remotes()[[remote]]
  if (length(url) == 0) {
    out$is_configured <- FALSE
    return(out)
  }
  out$is_configured <- TRUE
  out$url <- url

  # TODO: generalize here for GHE hosts that don't include 'github'
  parsed <- parse_github_remotes(url)
  # if the protocol is ssh, I suppose we can't assume a PAT, i.e. it's better
  # to use the Git approach vs. the GitHub API approach
  if (grepl("github", parsed$host) && parsed$protocol == "https") {
    remote_dat <- github_remotes(remote, github_get = NA)
    out$repo_spec <- remote_dat$repo_spec
    out$default_branch <- remote_dat$default_branch
    return(out)
  }

  out$default_branch <- tryCatch(
    {
      gert::git_fetch(remote = remote, repo = repo, verbose = FALSE)
      res <- gert::git_remote_ls(remote = remote, verbose = FALSE, repo = repo)
      path_file(res$symref[res$ref == "HEAD"])
    },
    error = function(e) NA_character_
  )

  out
}

default_branch_candidates <- function() {
  c(
    "main",
    "master",
    # we use `where = "de_facto"` so that one can configure init.defaultBranch
    # *locally* (which is unusual, but possible) in a repo that uses an
    # unconventional default branch name
    git_cfg_get("init.defaultBranch", where = "de_facto")
  )
}

# `prefer` is available if you want to inject external information, such as
# the default branch of a remote
guess_local_default_branch <- function(prefer = NULL, verbose = FALSE) {
  repo <- git_repo()

  gb <- gert::git_branch_list(local = TRUE, repo = repo)[["name"]]
  if (length(gb) == 0) {
    ui_stop("
      Can't find any local branches.
      Do you need to make your first commit?")
  }

  candidates <- c(prefer, default_branch_candidates())
  first_matched <- function(x, table) table[min(match(x, table), na.rm = TRUE)]

  if (length(gb) == 1) {
    db <- gb
  } else if (any(gb %in% candidates)) {
    db <- first_matched(gb, candidates)
  } else {
    # TODO: perhaps this should be classed, so I can catch it and distinguish
    # from the ui_stop() above, where there are no local branches.
    ui_stop("
      Unable to guess which existing local branch plays the role of the default.")
  }

  if (verbose) {
    ui_info("
      Local branch {ui_value(db)} appears to play the role of \\
      the default branch.")
  }

  db
}

#' @export
#' @rdname git-default-branch
#' @param name Default name for the initial branch in new Git repositories.
#' @examples
#' \dontrun{
#' git_default_branch_configure()
#' }
git_default_branch_configure <- function(name = "main") {
  check_string(name)
  ui_done("Configuring {ui_field('init.defaultBranch')} as {ui_value(name)}.")
  ui_info("Remember: this only affects repos you create in the future.")
  use_git_config(scope = "user", `init.defaultBranch` = name)
  invisible(name)
}

#' @export
#' @rdname git-default-branch
#' @param current_local_default Name of the local branch that is currently
#'   functioning as the default branch. If unspecified, this can often be
#'   inferred.
#' @examples
#' \dontrun{
#' git_default_branch_rediscover()
#'
#' # you can always explicitly specify the local branch that's been playing the
#' # role of the default
#' git_default_branch_rediscover("unconventional_default_branch_name")
#' }
git_default_branch_rediscover <- function(current_local_default = NULL) {
  rediscover_default_branch(old_name = current_local_default)
}

#' @export
#' @rdname git-default-branch
#' @param from Name of the branch that is currently functioning as the default
#'   branch.
#' @param to New name for the default branch.
#' @examples
#' \dontrun{
#' git_default_branch_rename()
#'
#' # you can always explicitly specify one or both branch names
#' git_default_branch_rename(from = "this", to = "that")
#' }
git_default_branch_rename <- function(from = NULL, to = "main") {
  repo <- git_repo()
  maybe_name(from)
  check_name(to)

  if (!is.null(from) &&
      !gert::git_branch_exists(from, local = TRUE, repo = repo)) {
    ui_stop("Can't find existing branch named {ui_value(from)}.")
  }

  cfg <- github_remote_config(github_get = TRUE)
  check_for_config(cfg, ok_configs = c("ours", "fork", "no_github"))

  if (cfg$type == "no_github") {
    from <- from %||% guess_local_default_branch(verbose = TRUE)
    if (from == to) {
      ui_info("Local repo already has {ui_value(from)} as its default branch.")
    } else {
      ui_done("Moving local {ui_value(from)} branch to {ui_value(to)}.")
      gert::git_branch_move(branch = from, new_branch = to, repo = repo)
      rstudio_git_tickle()
      report_fishy_files(old_name = from, new_name = to)
    }
    return(invisible(to))
  }
  # cfg is now either fork or ours

  tr <- target_repo(cfg, role = "source", ask = FALSE)
  old_source_db <- tr$default_branch

  if (!isTRUE(tr$can_admin)) {
    ui_stop("
      You don't seem to have {ui_field('admin')} permissions for the source \\
      repo {ui_value(tr$repo_spec)}, which is required to rename the default \\
      branch.")
  }

  old_local_db <- from %||%
    guess_local_default_branch(old_source_db, verbose = FALSE)

  if (old_local_db != old_source_db) {
    ui_oops("
      It's weird that the current default branch for your local repo and \\
      the source repo are different:
      {ui_value(old_local_db)} (local) != {ui_value(old_source_db)} (source)")
    if (ui_nope(
      "Are you sure you want to proceed?",
      yes = "yes", no = "no", shuffle = FALSE)) {
        ui_oops("Cancelling.")
        return(invisible())
    }
  }

  source_update <- old_source_db != to
  if (source_update) {
    gh <- gh_tr(tr)
    gh(
      "POST /repos/{owner}/{repo}/branches/{from}/rename",
      from = old_source_db,
      new_name = to
    )
  }

  if (source_update) {
    ui_done("
      Default branch of the source repo {ui_value(tr$repo_spec)} has moved: \\
      {ui_value(old_source_db)} --> {ui_value(to)}")
  } else {
    ui_done("
      Default branch of source repo {ui_value(tr$repo_spec)} is \\
      {ui_value(to)}. Nothing to be done.")
  }

  report_fishy_files(old_name = old_local_db, new_name = to)

  rediscover_default_branch(old_name = old_local_db, report_on_source = FALSE)
}

rediscover_default_branch <- function(old_name = NULL, report_on_source = TRUE) {
  maybe_name(old_name)

  # GitHub's official TODOs re: manually updating local environments
  # after a source repo renames the default branch:

  # git branch -m OLD-BRANCH-NAME NEW-BRANCH-NAME
  # git fetch origin
  # git branch -u origin/NEW-BRANCH-NAME NEW-BRANCH-NAME
  # git remote set-head origin -a

  # optionally
  # git remote prune origin

  # Note: they are assuming the relevant repo is known as origin, but it could
  # just as easily be, e.g., upstream.

  repo <- git_repo()
  if (!is.null(old_name) &&
      !gert::git_branch_exists(old_name, local = TRUE, repo = repo)) {
    ui_stop("Can't find existing local branch named {ui_value(old_name)}.")
  }

  cfg <- github_remote_config(github_get = TRUE)
  check_for_config(cfg)

  tr <- target_repo(cfg, role = "source", ask = FALSE)
  db <- tr$default_branch

  # goal, in Git-speak: git remote set-head <remote> -a
  # goal, for humans: learn and record the default branch (i.e. the target of
  # the symbolic-ref refs/remotes/<remote>/HEAD) for the named remote
  # https://git-scm.com/docs/git-remote#Documentation/git-remote.txt-emset-headem
  # for very stale repos, a fetch is a necessary pre-requisite
  # I provide `refspec = db` to avoid fetching all refs, which can be VERY slow
  # for a repo like ggplot2 (several minutes, with no progress reporting)
  gert::git_fetch(remote = tr$name, refspec = db, verbose = FALSE, repo = repo)
  gert::git_remote_ls(remote = tr$name, verbose = FALSE, repo = repo)

  old_name <- old_name %||% guess_local_default_branch(db, verbose = FALSE)

  local_update <- old_name != db
  if (local_update) {
    # goal, in Git-speak: git branch -m <old_name> <db>
    gert::git_branch_move(branch = old_name, new_branch = db, repo = repo)
    rstudio_git_tickle()
  }

  # goal, in Git-speak: git branch -u <remote>/<db> <db>
  gert::git_branch_set_upstream(
    branch = db,
    upstream = glue("{tr$name}/{db}"),
    repo = repo
  )

  # goal: get rid of old remote tracking branch, e.g. origin/master
  # goal, in Git-speak: git remote prune origin
  # I provide a refspec to avoid fetching all refs, which can be VERY slow
  # for a repo like ggplot2 (several minutes, with no progress reporting)
  gert::git_fetch(
    remote = tr$name,
    refspec = glue("refs/heads/{old_name}:refs/remotes/{tr$name}/{old_name}"),
    verbose = FALSE, repo = repo, prune = TRUE
  )

  # for "ours" and "theirs", the source repo is the only remote on our radar and
  # we're done ingesting the default branch from the source repo
  # but for "fork", we also need to update
  #   the fork = the user's primary repo = the remote known as origin
  if (cfg$type == "fork") {
    old_name_fork <- cfg$origin$default_branch
    fork_update <- old_name_fork != db
    if (fork_update) {
      gh <- gh_tr(cfg$origin)
      gh(
        "POST /repos/{owner}/{repo}/branches/{from}/rename",
        from = old_name_fork,
        new_name = db
      )
      gert::git_fetch(remote = "origin", refspec = db, verbose = FALSE, repo = repo)
      gert::git_remote_ls(remote = "origin", verbose = FALSE, repo = repo)
      gert::git_fetch(
        remote = "origin",
        refspec = glue("refs/heads/{old_name}:refs/remotes/origin/{old_name}"),
        verbose = FALSE, repo = repo, prune = TRUE
      )
    }
  }

  if (report_on_source) {
    ui_info("
      Default branch of the source repo {ui_value(tr$repo_spec)}: {ui_value(db)}")
  }

  if (local_update) {
    ui_done("
      Default branch of local repo has moved: \\
      {ui_value(old_name)} --> {ui_value(db)}")
  } else {
    ui_done("
      Default branch of local repo is {ui_value(db)}. Nothing to be done.")
  }

  if (cfg$type == "fork") {
    if (fork_update) {
      ui_done("
        Default branch of your fork has moved: \\
        {ui_value(old_name_fork)} --> {ui_value(db)}")
    } else {
      ui_done("
        Default branch of your fork is {ui_value(db)}. Nothing to be done.")
    }
  }

  invisible(db)
}

challenge_non_default_branch <- function(details = "Are you sure you want to proceed?",
                                         default_branch = NULL) {
  actual <- git_branch()
  default_branch <- default_branch %||% git_default_branch()
  if (nzchar(details)) {
    details <- paste0("\n", details)
  }
  if (actual != default_branch) {
    if (ui_nope("
      Current branch ({ui_value(actual)}) is not repo's default \\
      branch ({ui_value(default_branch)}).{details}")) {
      ui_stop("Cancelling. Not on desired branch.")
    }
  }
  invisible()
}

report_fishy_files <- function(old_name = "master", new_name = "main") {
  ui_todo("
    Be sure to update files that refer to the default branch by name.
    Consider searching within your project for {ui_value(old_name)}.")
  # I don't want failure of a fishy file check to EVER cause
  # git_default_branch_rename() to fail and prevent the call to
  # git_default_branch_rediscover()
  # using a simple try() wrapper because these hints are just "nice to have"
  try(fishy_github_actions(new_name = new_name), silent = TRUE)
  try(fishy_badges(old_name = old_name), silent = TRUE)
  try(fishy_bookdown_config(old_name = old_name), silent = TRUE)
}

# good test cases: downlit, purrr, pkgbuild, zealot, glue, bench,
# textshaping, scales
fishy_github_actions <- function(new_name = "main") {
  if (!uses_github_actions()) {
    return(invisible(character()))
  }
  workflow_dir <- proj_path(".github", "workflows")
  workflows <- dir_ls(workflow_dir, regexp = "[.]ya?ml$")

  f <- function(pth, new_name) {
    x <- yaml::read_yaml(pth)
    x_unlisted <- unlist(x)
    locs <- grep("branches", re_match(names(x_unlisted), "[^//.]+$")$.match)
    branches <- x_unlisted[locs]
    length(branches) == 0 || new_name %in% branches
  }

  includes_branch_name <- map_lgl(workflows, f, new_name = new_name)
  paths <- proj_rel_path(workflows[!includes_branch_name])

  if (length(paths) == 0) {
    return(invisible(character()))
  }

  paths <- sort(paths)
  ui_paths <- map_chr(paths, ui_path)

  ui_oops(c(
    "These GitHub Action files don't mention the new default branch {ui_value(new_name)}:",
    paste0("- ", ui_paths)
  ))

  invisible(paths)
}

fishy_badges <- function(old_name = "master") {
  path <- find_readme()
  if (is.null(path)) {
    return(invisible(character()))
  }

  readme_lines <- read_utf8(path)
  badge_lines_range <- block_find(
    readme_lines,
    block_start = badge_start,
    block_end = badge_end
  )
  if (length(badge_lines_range) != 2) {
    return(invisible(character()))
  }
  badge_lines <- readme_lines[badge_lines_range[1]:badge_lines_range[2]]

  if (!any(grepl(old_name, badge_lines))) {
    return(invisible(character()))
  }

  ui_path <- ui_path(proj_rel_path(path))
  ui_oops(c(
    "Some badges may refer to the old default branch {ui_value(old_name)}:",
    paste0("- ", ui_path)
  ))

  invisible(path)
}

fishy_bookdown_config <- function(old_name = "master") {
  # https://github.com/dncamp/shift/blob/a12a3fb0cd30ae864525f7a9f1f907a05f15f9a3/_bookdown.yml
  # https://github.com/Jattan08/Wonderland/blob/b9e7ddc694871d1d13a2a02abe2d3b4a944c4653/_bookdown.yml
  # edit: https://github.com/dncamp/shift/edit/master/%s
  # view: https://github.com/dncamp/shift/blob/master/%s
  # history: https://github.com/YOUR GITHUB USERNAME/YOUR REPO NAME/commits/master/%s
  bookdown_config <- dir_ls(
    proj_get(),
    regexp = "_bookdown[.]ya?ml$",
    recurse = TRUE
  )
  if (length(bookdown_config) == 0) {
    return(invisible(character()))
  }
  # I am (very weakly) worried about more than 1 match, hence the [[1]]
  bookdown_config <- purrr::discard(bookdown_config, ~ grepl("revdep", .x))[[1]]

  bookdown_config_lines <- read_utf8(bookdown_config)
  linky_lines <- grep("^(edit|view|history)", bookdown_config_lines, value = TRUE)

  if (!any(grepl(old_name, linky_lines))) {
    return(invisible(character()))
  }

  ui_path <- ui_path(proj_rel_path(bookdown_config))
  ui_oops(c(
    "The bookdown configuration file may refer to the old default branch {ui_value(old_name)}:",
    paste0("- ", ui_path)
  ))

  invisible(path)
}
