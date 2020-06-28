# Repository -------------------------------------------------------------------
git_repo <- function() {
  check_uses_git()
  proj_get()
}

git2r_repo <- function() {
  check_uses_git()
  git2r::repository(proj_get())
}

uses_git <- function() {
  repo <- tryCatch(
    gert::git_find(proj_get()),
    error = function(e) NULL
  )
  !is.null(repo)
}

check_uses_git <- function() {
  if (uses_git()) {
    return(invisible())
  }

  ui_stop(c(
    "Cannot detect that project is already a Git repository.",
    "Do you need to run {ui_code('use_git()')}?"
  ))
}

git_init <- function() {
  gert::git_init(proj_get())
}

# Config -----------------------------------------------------------------------

# `where = "de_facto"` means look at the values that are "in force", i.e. where
# local repo variables override global user-level variables, when both are
# defined
#
# `where = "local"` is strict, i.e. it only returns a value that is in the local
# config
git_cfg_get <- function(name, where = c("de_facto", "local", "global")) {
  where <- match.arg(where)
  dat <- switch(
    where,
    global = gert::git_config_global(),
    gert::git_config(git_repo())
  )
  if (where == "local") {
    dat <- dat[dat$level == "local", ]
  }
  out <- dat$value[dat$name == name]
  if (length(out) > 0) out else NULL
}

# Status------------------------------------------------------------------------
git_status <- function(untracked) {
  stopifnot(is_true(untracked) || is_false(untracked))
  st <- gert::git_status(repo = git_repo())
  if (!untracked) {
    st <- st[st$status != "new", ]
  }
  st
}

# Commit -----------------------------------------------------------------------
git_ask_commit <- function(message, untracked, paths = NULL) {
  if (!is_interactive() || !uses_git()) {
    return(invisible())
  }
  on.exit(rstudio_git_tickle(), add = TRUE)

  # this is defined here to encourage all commits to route through this function
  git_commit <- function(paths, message) {
    repo <- git_repo()
    ui_done("Adding files")
    gert::git_add(paths, repo = repo)
    ui_done("Making a commit with message {ui_value(message)}")
    gert::git_commit(message, repo = repo)
    rstudio_git_tickle()
  }

  uncommitted <- git_status(untracked)$file
  if (is.null(paths)) {
    paths <- uncommitted
  } else {
    paths <- intersect(paths, uncommitted)
  }
  n <- length(paths)
  if (n == 0) {
    return(invisible())
  }

  paths <- sort(paths)
  ui_paths <- purrr::map_chr(paths, ui_path)
  if (n > 20) {
    ui_paths <- c(ui_paths[1:20], "...")
  }

  ui_line(c(
    "There are {n} uncommitted files:",
    paste0("* ", ui_paths)
  ))

  if (ui_yeah("Is it ok to commit them?")) {
    git_commit(paths, message)
  }
  invisible()
}

git_commit_find <- function(refspec = NULL) {
  repo <- git2r_repo()

  if (is.null(refspec)) {
    git2r::last_commit(repo)
  } else {
    git2r::revparse_single(repo, refspec)
  }
}

git_uncommitted <- function(untracked = FALSE) {
  nrow(git_status(untracked)) > 0
}

check_no_uncommitted_changes <- function(untracked = FALSE) {
  if (!uses_git()) {
    return(invisible())
  }

  if (rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }

  if (git_uncommitted(untracked = untracked)) {
    if (ui_yeah("There are uncommitted changes. Do you want to proceed anyway?")) {
      return(invisible())
    } else {
      ui_stop("Uncommitted changes. Please commit before continuing.")
    }
  }
}

git_conflict_report <- function() {
  st <- git_status(untracked = FALSE)
  conflicted <- st$file[st$status == "conflicted"]
  n <- length(conflicted)
  if (n == 0) {
    return(invisible())
  }

  conflicted_paths <- purrr::map_chr(conflicted, ui_path)
  ui_line(c(
    "There are {n} conflicted files:",
    paste0("* ", conflicted_paths)
  ))
  ui_silence(purrr::walk(conflicted, edit_file))

  ui_stop(c(
    "Please fix, stage, and commit to continue",
    "Or run {ui_code('git merge --abort')} in the terminal"
  ))
}

# Remotes ----------------------------------------------------------------------
## remref --> remote, branch
git_parse_remref <- function(remref) {
  regex <- paste0("^", names(git_remotes()), collapse = "|")
  regex <- glue("({regex})/(.*)")
  list(remote = sub(regex, "\\1", remref), branch = sub(regex, "\\2", remref))
}

remref_remote <- function(remref) git_parse_remref(remref)$remote
remref_branch <- function(remref) git_parse_remref(remref)$branch

git_is_fork <- function() {
  # TODO: this will surely change again soon, to reflect a direct test whether
  # the relevant remote (that is also a github repo) is a fork
  "upstream" %in% names(git_remotes())
}

# Pull -------------------------------------------------------------------------
git_pull <- function(remref = NULL) {
  repo <- git_repo()
  branch <- git_branch()
  remref <- remref %||% git_branch_upstream(branch)
  if (is.na(remref)) {
    ui_stop("
      Can't pull when no remote ref is specified and local branch \\
      {ui_value(branch)} has no upstream tracking branch")
  }
  stopifnot(is_string(remref))
  gert::git_fetch(
    remote = remref_remote(remref),
    refspec = remref_branch(branch),
    repo = repo,
    verbose = FALSE
  )
  gert::git_merge(remref, repo = repo)
  st <- git_status(untracked = TRUE)
  if (any(st$status == "conflicted")) {
    git_conflict_report()
  }

  invisible()
}

# Branch ------------------------------------------------------------------
git_branch <- function() {
  info <- gert::git_info(git_repo())
  branch <- info$shorthand
  if (identical(branch, "HEAD")) {
    ui_stop("Detached head; can't continue")
  }
  if (is.na(branch)) {
    ui_stop("On an unborn branch -- do you need to make an initial commit?")
  }
  branch
}

git_branch_exists <- function(branch) {
  branches <- gert::git_branch_list(git_repo())
  branch %in% branches$name
}

git_branch_upstream <- function(branch = git_branch()) {
  info <- gert::git_branch_list(git_repo())
  this <- info$local & info$name == branch
  if (sum(this) < 1) {
    ui_stop("There is no local branch named {ui_value(branch}")
  }
  sub("^refs/remotes/", "", info$upstream[this])
}

git_branch_tracking <- function(branch = git_branch()) {
  # TODO: this will be broken until I come back here and gert-ify it
  b <- git_branch_OLD(name = branch)
  git2r::branch_get_upstream(b)$name
}

## FIXME: this function is 50% "actual tracking branch" and
## 50% "what we think tracking branch should be"
## different uses need to be untangled, then we can give a better name
git_branch_tracking_FIXME <- function(branch = git_branch()) {
  if (identical(branch, "master") && git_is_fork()) {
    # We always pretend that the master branch of a fork tracks the
    # master branch in the source repo
    "upstream/master"
  } else {
    git_branch_tracking(branch)
  }
}

git_branch_create_and_switch <- function(branch, ref = NULL) {
  gert::git_branch_create(branch, ref = ref %||% "HEAD", repo = git_repo())
  rstudio_git_tickle()
}

git_branch_switch <- function(branch) {
  gert::git_branch_checkout(branch, repo = git_repo())
  rstudio_git_tickle()
}

git_branch_compare <- function(branch = git_branch(), remref = NULL) {
  remref <- remref %||% git_branch_upstream(branch)
  gert::git_fetch(
    remote = remref_remote(remref),
    refspec = remref_branch(remref),
    repo = git_repo(),
    verbose = FALSE
  )
  # TODO: replace with something from gert
  out <- git2r::ahead_behind(
    git2r::revparse_single(repo = git2r_repo(), revision = branch),
    git2r::revparse_single(repo = git2r_repo(), revision = remref)
  )
  stats::setNames(as.list(out), nm = c("local_only", "remote_only"))
}

git_branch_push <- function(branch = git_branch(),
                            remote_name = NULL,
                            remote_branch = NULL,
                            credentials = NULL,
                            force = FALSE) {
  remote_info   <- git_branch_remote(branch)
  remote_name   <- remote_name %||% remote_info$remote_name
  remote_branch <- remote_branch %||% remote_info$remote_branch

  remote <- paste0(remote_name, ":", remote_branch)
  ui_done("Pushing local {ui_value(branch)} branch to {ui_value(remote)}")
  git2r::push(
    git2r_repo(),
    name = remote_name,
    refspec = glue("refs/heads/{branch}:refs/heads/{remote_branch}"),
    force = force,
    credentials = credentials
  )
  rstudio_git_tickle()
}

git_branch_remote <- function(branch = git_branch()) {
  remote <- git_branch_tracking_FIXME(branch)
  if (is.null(remote)) {
    list(
      remote_name   = "origin",
      remote_branch = branch
    )
  } else {
    list(
      remote_name   = remref_remote(remote),
      remote_branch = remref_branch(remote)
    )
  }
}

git_branch_track <- function(branch, remote = "origin", remote_branch = branch) {
  # TODO: this will be broken until I come back here and gert-ify it
  branch_obj <- git_branch_OLD(branch)
  upstream <- glue("{remote}/{remote_branch}")
  ui_done("Setting upstream tracking branch for {ui_value(branch)} to {ui_value(upstream)}")
  git2r::branch_set_upstream(branch_obj, upstream)
}

# Checks ------------------------------------------------------------------
check_branch_not_master <- function() {
  if (git_branch() != "master") {
    return()
  }

  # TODO: this wording is overly specific. Do better once `pr_status()` is
  # implemented and we can offer an overview of existing (PR) branches.
  ui_stop(
    "
    Currently on {ui_value('master')} branch.
    Do you need to call {ui_code('pr_init()')} first?
    "
  )
}

check_branch <- function(branch) {
  ui_done("Checking that current branch is {ui_value(branch)}")
  actual <- git_branch()
  if (actual == branch) {
    return(invisible())
  }
  code <- glue("git checkout {branch}")
  ui_stop(
    "
    Must be on branch {ui_value(branch)}, not {ui_value(actual)}.
    How to switch to the correct branch in the shell:
    {ui_code(code)}
    "
  )
}

# examples of remref: upstream/master, origin/foofy
check_branch_up_to_date <- function(direction = c("pull", "push"),
                                    remref = NULL,
                                    use = NULL) {
  direction <- match.arg(direction)
  branch <- git_branch()
  remref <- remref %||% git_branch_upstream(branch)
  use <- use %||% switch(direction, pull = "git pull", push = "git push")

  if (is.na(remref)) {
    ui_done("Local branch {ui_value(branch)} is not tracking a remote branch.")
    return(invisible())
  }

  if (direction == "pull") {
    ui_done("
      Checking that local branch {ui_value(branch)} has the changes \\
      in {ui_value(remref)}")
  } else {
    ui_done("
      Checking that remote branch {ui_value(remref)} has the changes \\
      in {ui_value(branch)}")
  }

  comparison <- git_branch_compare(branch, remref)

  # TODO: properly pluralize "commit(s)" when I switch to cli
  if (direction == "pull") {
    if (comparison$remote_only == 0) {
      return(invisible())
    } else {
      ui_stop("
        Local branch {ui_value(branch)} is behind {ui_value(remref)} by \\
        {comparison$remote_only} commit(s).
        Please use {ui_code(use)} to update.")
    }
  } else {
    if (comparison$local_only == 0) {
      return(invisible())
    } else {
      ui_stop("
        Local branch {ui_value(branch)} is ahead of {ui_value(remref)} by \\
        {comparison$local_only} commit(s).
        Please use {ui_code(use)} to update.")
    }
  }
}

check_branch_pulled <- function(remref = NULL, use = NULL) {
  check_branch_up_to_date(direction = "pull", remref = remref, use = use)
}

check_branch_pushed <- function(remref = NULL, use = NULL) {
  check_branch_up_to_date(direction = "pull", remref = remref, use = use)
}
