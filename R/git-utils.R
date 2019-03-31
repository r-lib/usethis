# Repository --------------------------------------------------------------

git_repo <- function() {
  check_uses_git()
  git2r::repository(proj_get())
}

git_init <- function() {
  git2r::init(proj_get())
}

git_pull <- function(remote_branch = git_branch_tracking(),
                     credentials = NULL) {
  repo <- git_repo()

  git2r::fetch(
    repo,
    name = remref_remote(remote_branch),
    refspec = remref_branch(remote_branch),
    verbose = FALSE,
    credentials = credentials
  )
  mr <- git2r::merge(repo, remote_branch)
  if (isTRUE(mr$conflicts)) {
    stop("Merge conflict! Please resolve before continuing", call. = FALSE)
  }

  invisible()
}

git_status <- function() {
  git2r::status(git_repo())
}

uses_git <- function(path = proj_get()) {
  !is.null(git2r::discover_repository(path))
}

# Remotes ------------------------------------------------------------------

git_remote_find <- function(rname = "origin") {
  remotes <- git_remotes()
  if (length(remotes) == 0) return(NULL)
  remotes[[rname]]
}

git_remote_exists <- function(rname = "origin") {
  rname %in% names(git_remotes())
}

# GitHub ------------------------------------------------------------------

git_is_fork <- function() {
  git_remote_exists("upstream")
}

# Commit ------------------------------------------------------------------

git_commit_find <- function(refspec = NULL) {
  repo <- git_repo()

  if (is.null(refspec)) {
    git2r::last_commit(repo)
  } else {
    git2r::revparse_single(repo, refspec)
  }
}

# Remote refs -------------------------------------------------------------
git_remref <- function(remote = "origin", branch = "master") {
  glue("{remote}/{branch}")
}

## remref --> remote, branch
git_parse_remref <- function(remref) {
  repo <- git_repo()
  rnames <- git2r::remotes(repo)
  rnames <- paste0("^", rnames, collapse = "|")
  regex <- glue("({rnames})/(.*)")
  list(remote = sub(regex, "\\1", remref), branch = sub(regex, "\\2", remref))
}

remref_remote <- function(remref) git_parse_remref(remref)$remote
remref_branch <- function(remref) git_parse_remref(remref)$branch

# Branch ------------------------------------------------------------------
git_branch <- function(name = NULL) {
  if (is.null(name)) {
    return(git_branch_current())
  }
  b <- git2r::branches(git_repo())
  b[[name]]
}

git_branch_current <- function() {
  repo <- git_repo()

  branch <- git2r::repository_head(repo)
  if (!git2r::is_branch(branch)) {
    ui_stop("Detached head; can't continue")
  }
  branch
}

git_branch_name <- function() {
  git_branch_current()$name
}

git_branch_exists <- function(branch) {
  repo <- git_repo()
  branch %in% names(git2r::branches(repo))
}

git_branch_tracking <- function(branch = git_branch_name()) {
  if (identical(branch, "master") && git_is_fork()) {
    # We always pretend that the master branch of a fork tracks the
    # master branch in the source repo
    "upstream/master"
  } else {
    b <- git_branch(name = branch)
    git2r::branch_get_upstream(b)$name
  }
}

git_branch_create <- function(branch, commit = NULL) {
  git2r::branch_create(git_commit_find(commit), branch)
}

git_branch_switch <- function(branch) {
  old <- git_branch_current()
  git2r::checkout(git_repo(), branch)
  invisible(old)
}

git_branch_compare <- function(branch = git_branch_name()) {
  repo <- git_repo()

  remref <- git_branch_tracking(branch)
  git2r::fetch(
    repo,
    name = remref_remote(remref),
    refspec = branch,
    verbose = FALSE
  )
  git2r::ahead_behind(
    git_commit_find(branch),
    git_commit_find(remref)
  )
}

git_branch_push <- function(branch = git_branch_name(),
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
    git_repo(),
    name = remote_name,
    refspec = glue("refs/heads/{branch}:refs/heads/{remote_branch}"),
    force = force,
    credentials = credentials
  )
}

git_branch_remote <- function(branch = git_branch_name()) {
  remote <- git_branch_tracking(branch)
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
  branch_obj <- git_branch(branch)
  upstream <- git_remref(remote, remote_branch)
  ui_done("Setting upstream tracking branch for {ui_value(branch)} to {ui_value(upstream)}")
  git2r::branch_set_upstream(branch_obj, upstream)
}

git_branch_delete <- function(branch) {
  branch <- git_branch(branch)
  git2r::branch_delete(branch)
}

# Checks ------------------------------------------------------------------

check_uses_git <- function(base_path = proj_get()) {
  if (uses_git(base_path)) {
    return(invisible())
  }

  ui_stop(c(
    "Cannot detect that project is already a Git repository.",
    "Do you need to run {ui_code('use_git()')}?"
  ))
}

check_uncommitted_changes <- function(path = proj_get(), untracked = FALSE) {
  if (rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }

  if (uses_git(path) && git_uncommitted(path, untracked = untracked)) {
    ui_stop("Uncommited changes. Please commit to git before continuing.")
  }
}

git_uncommitted <- function(path = proj_get(), untracked = FALSE) {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r, untracked = untracked), length, integer(1))
  any(st != 0)
}

check_branch_not_master <- function() {
  if (git_branch_name() != "master") {
    return()
  }

  ui_stop(
    "
    Currently on {ui_value('master')} branch.
    Do you need to call {ui_code('pr_init()')} first?
    "
  )
}

check_branch <- function(branch) {
  ui_done("Checking that current branch is {ui_value(branch)}")
  actual <- git_branch_name()
  if (actual == branch) return()
  code <- glue("git checkout {branch}")
  ui_stop(
    "
    Must be on branch {ui_value(branch)}, not {ui_value(actual)}.
    How to switch to the correct branch in the shell:
    {ui_code(code)}
    "
  )
}

check_branch_pulled <- function(branch = git_branch_name(), use = "git pull") {
  remote <- git_branch_tracking(branch)
  ui_done(
    "Checking that local branch {ui_value(branch)} has the changes \\
     in {ui_value(remote)}"
  )

  diff <- git_branch_compare(branch)
  if (diff[[2]] == 0) {
    return(invisible())
  }

  ui_stop(c(
    "Local branch {ui_value(branch)} is behind {ui_value(remote)}.",
    "Please use {ui_code(use)} to update."
  ))
}

check_branch_pushed <- function(branch = git_branch_name(), use = "git push") {
  local <- paste0("local/", branch)
  remote <- git_branch_tracking(branch)
  ui_done(
    "Checking that remote branch {ui_value(remote)} has the changes \\
     in {ui_value(local)}"
  )

  diff <- git_branch_compare(branch)
  if (diff[[1]] == 0) {
    return(invisible())
  }

  ui_stop(c(
    "{ui_value(remote)} is behind {ui_value(local)}",
    "Please use {ui_code(use)} to update."
  ))
}

# config ------------------------------------------------------------------

git_config_get <- function(name, global = FALSE) {
  if (global) {
    config <- git2r::config()
    config$global[[name]]
  } else {
    config <- git2r::config(git_repo())
    config$local[[name]]
  }
}

git_config_set <- function(name, value, global = FALSE) {
  old <- git_config_get(name, global = global)

  config <- list(git_repo(), value, global)
  names(config) <- c("repo", name, "global")
  do.call(git2r::config, config)

  invisible(old)
}

git_config <- function(..., .repo = NULL) {
  values <- list(...)

  if (is.null(.repo)) {
    old <- git2r::config()$global[names(values)]
    do.call(git2r::config, c(list(global = TRUE), values))
  } else {
    old <- git2r::config(.repo)$local[names(values)]
    do.call(git2r::config, c(list(repo = .repo), values))
  }

  names(old) <- names(values)
  invisible(old)
}


# Auth --------------------------------------------------------------------

git_has_ssh <- function() {
  tryCatch(
    error = function(err) FALSE,
    {
      git2r::cred_ssh_key()
      TRUE
    }
  )
}
