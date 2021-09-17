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
#' determines the name of the branch that gets created when you make the first
#' commit in a new Git repo. `init.defaultBranch` only affects the local Git
#' repos you create in the future.
#'

#' @section `git_default_branch`:

#' TODO: UPDATE THIS ONCE I OVERHAUL THE FUNCTION ITSELF.
#'
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

#' @section `git_default_branch_rediscover()`:

#' This consults an external authority -- specifically, the remote **source
#' repo** -- to learn the default branch of the current project / repo. If that
#' appears to have changed, such as from `master` to `main`, we do the
#' corresponding branch renaming in your local repo and, if relevant, in your
#' fork.
#'
#' See <https://happygitwithr.com/common-remote-setups.html> for more about
#' GitHub remote configurations and, e.g., what we mean by the source repo. This
#' function works for the configurations `"ours"`, `"fork"`, and `"theirs"`.

#' @section `git_default_branch_rename()`:

#' Note: this only works for a repo that you effectively own. In terms of
#' GitHub, you must own the **source repo** personally or, if
#' organization-owned, you must have `admin` permission on the **source repo**.
#'
#' This renames the default branch in the **source repo** and then calls
#' `git_default_branch_rediscover()`, to make any necessary changes in the local
#' repo and, if relevant, in your personal fork.
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

  possibly_git_default_branch_remote <- purrr::possibly(
    git_default_branch_remote,
    otherwise = NULL
  )
  db_source <- possibly_git_default_branch_remote("upstream") %||%
    possibly_git_default_branch_remote("origin") %||%
    character()

  db_local_with_source <- tryCatch(
    guess_local_default_branch(db_source),
    error = function(e) NA_character_
  )

  if (is.na(db_local_with_source)) {
    if (length(db_source)) {
      ui_stop("
        The source repo's default branch is {ui_value(db_source)}.
        But the local repo has no branch named {ui_value(db_source)}.
        Call {ui_code('git_default_branch_rediscover()')}, using the \\
        {ui_code('current_local_name')} argument, to resolve this.")
    } else {
      ui_stop("Can't determine the default branch.")
    }
  }
  # we learned a default branch from the local repo

  if (length(db_source) < 1) {
    return(db_local_with_source)
  }
  # we learned a default branch from the source repo

  if (db_source == db_local_with_source) {
    return(db_source)
  }
  # we learned a default branch from both local and source repos,
  # BUT they don't match

  ui_stop("
    Local repo suggests the default branch is {ui_value(db_local_with_source)}.
    However, the source repo's default branch is {ui_value(db_source)}.
    Call {ui_code('git_default_branch_rediscover()')} to resolve this.")
}

#' @export
#' @rdname git-default-branch
git_default_branch_legacy <- function() {
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
  # TODO: should I call use_git_config()?
  gert::git_config_global_set("init.defaultBranch", name)
  invisible(name)
}

#' @export
#' @rdname git-default-branch
#' @param current_local_name Name of the local branch that is currently
#'   functioning as the default branch. If unspecified, this can often be
#'   inferred.
#' @examples
#' \dontrun{
#' git_default_branch_rediscover()
#'
#' # you can always explicitly specify the local branch that's been playing the
#' # role of the default
#' git_default_branch_rediscover("unconventional_branch_name")
#' }
git_default_branch_rediscover <- function(current_local_name = NULL) {
  rediscover_default_branch(old_name = current_local_name, verbose = TRUE)
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
#' # you can always explicitly specify the branch names
#' git_default_branch_rename(from = "this", to = "that")
#' }
git_default_branch_rename <- function(from = NULL, to = "main") {
  #rename_default_branch(old_name = from, new_name = to)
  ui_done('
    Renaming (a.k.a. "moving") the default branch for {ui_value(project_name())}.')
  repo <- git_repo()
  maybe_string(from)
  check_string(to)

  if (!is.null(from) &&
      !gert::git_branch_exists(from, local = TRUE, repo = repo)) {
    ui_stop("Can't find existing branch named {ui_value(from)}.")
  }

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

  old_local_db <- from %||%
    guess_local_default_branch(old_source_db, verbose = TRUE)

  if (old_local_db != old_source_db) {
    ui_oops("
      It's weird that the current default branch for your local repo and \\
      the source repo are different:
      {ui_value(old_local_db)} (local) != {ui_value(old_source_db)} (source)")
    if (ui_nope(
      "Are you sure you want to proceed?",
      yes = "yes", no = "no", shuffle = FALSE)) {
      ui_stop("Cancelling.")
    }
  }

  if (to == old_source_db) {
    ui_info("
      Source repo {ui_value(tr$repo_spec)} already has \\
      {ui_value(old_source_db)} as its default branch.")
  } else {
    gh <- gh_tr(tr)
    ui_done("
      Renaming {ui_value(old_source_db)} branch to {ui_value(to)} in \\
      the source repo {ui_value(tr$repo_spec)}.")
    gh(
      "POST /repos/{owner}/{repo}/branches/{from}/rename",
      from = old_source_db,
      new_name = to
    )
  }

  rediscover_default_branch(old_name = old_local_db, verbose = FALSE)
}

# `verbose = FALSE` exists only so we can call this at the end of
# git_default_branch_rename() and suppress some of the redundant messages
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

  old_name <- old_name %||% guess_local_default_branch(db, verbose = TRUE)

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

git_default_branch_remote <- function(remote = "origin") {
  url <- git_remotes()[[remote]]
  if (length(url) == 0) {
    ui_stop("There is no remote named {ui_value(remote)}.")
  }

  # if 'remote' is configured, but does not exist (or we don't have access),
  # both the github and the non-github branch below will return NA
  # I'm beginning to wonder if I should error for the "404 not found" case, but
  # that's a more general concern and I won't solve it in this default branch
  # work

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

default_branch_candidates <- function() {
  init_default_branch <- git_cfg_get("init.defaultBranch", where = "global")
  c(
    "main",
    "master",
    init_default_branch
  )
}

# `prefer` is available if you want to inject external information, such as
# the default branch of a remote, e.g. the result of
# git_default_branch_remote("upstream") and/or
# git_default_branch_remote("origin")
guess_local_default_branch <- function(prefer = character(), verbose = FALSE) {
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
    propose <- gb
  } else if (any(gb %in% candidates)) {
    propose <- first_matched(gb, candidates)
  } else {
    # I'm starting to suspect this should be classed, so I can catch it and
    # distinguish from the ui_stop() above, where there are no local branches.
    ui_stop("
      Not clear which existing local branch plays the role of the default.")
  }

  # TODO: do I really want to emit a message here?
  # dilemma: sometimes I call this directly and want the message
  # but I'm also calling it in git_default_branch() and it's leading to too
  # much message
  if (verbose) {
    ui_done("
      Local branch {ui_value(propose)} appears to play the role of \\
      the default branch.")
  }

  propose
}

# TODO: this needs more work
check_default_branch <- function() {
  default_branch <- tryCatch(
    error = function(e) NA_character_,
    git_default_branch()
  )
  if (!is.na(default_branch)) {
    return(invisible(default_branch))
  }

  ui_stop("
    THIS FUNCTION needs to determine the default branch of this repo, but it \\
    can't.
    Call {ui_code('git_default_branch()')} to get more diagnostic information.")
}

challenge_non_default_branch <- function(details = "Are you sure you want to proceed?") {
  actual <- git_branch()
  ui_done("Determining this repo's default branch.")
  default_branch <- git_default_branch()
  if (nzchar(details)) {
    details <- paste0("\n", details)
  }
  if (actual != default_branch) {
    if (ui_nope("
      Current branch ({ui_value(actual)}) is not repo's default \\
      branch ({ui_value(default_branch)}){details}")) {
      ui_stop("Aborting")
    }
  }
}

# Bring some of this back, e.g. the messaging.
# check_pr_branch <- function() {
#   default_branch <- git_default_branch_legacy()
#   if (git_branch() != default_branch) {
#     return(invisible())
#   }
#   ui_stop("
#     The {ui_code('pr_*()')} functions facilitate pull requests.
#     The current branch ({ui_value(default_branch)}) is this repo's default \\
#     branch, but pull requests should NOT come from the default branch.
#     Do you need to call {ui_code('pr_init()')} (new PR)?
#     Or {ui_code('pr_resume()')} or {ui_code('pr_fetch()')} (existing PR)?")
# }
