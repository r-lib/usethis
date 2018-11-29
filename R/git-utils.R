# Repository --------------------------------------------------------------

git_repo <- function() {
  check_uses_git()
  git2r::repository(proj_path())
}

git_init <- function() {
  git2r::init(proj_get())
}

uses_git <- function(path = proj_get()) {
  !is.null(git2r::discover_repository(path))
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

# Branch ------------------------------------------------------------------

git_branch_name <- function() {
  repo <- git_repo()

  branch <- git2r::repository_head(repo)
  if (!git2r::is_branch(branch)) {
    stop("Detached head; can't continue", call. = FALSE)
  }

  branch$name
}

git_branch_exists <- function(branch) {
  repo <- git_repo()
  branch %in% names(git2r::branches(repo))
}

git_branch_create <- function(branch, commit = NULL) {
  git2r::branch_create(git_commit_find(commit), branch)
}

git_branch_switch <- function(branch) {
  git2r::checkout(git_repo(), branch)
}

git_branch_compare <- function(branch = git_branch_name()) {
  repo <- git_repo()
  git2r::fetch(repo, "origin", refspec = branch, verbose = FALSE)
  git2r::ahead_behind(
    git_commit_find(branch),
    git_commit_find(paste0("origin/", branch))
  )
}

git_branch_push <- function(branch = git_branch_name(), force = FALSE) {
  branch_obj <- git2r::branches(git_repo())[[branch]]

  upstream <- git2r::branch_get_upstream(branch_obj)
  if (is.null(upstream)) {
    name <- "origin"
  } else {
    name <- git2r::branch_remote_name(upstream)
  }

  git2r::push(
    git_repo(),
    name = name,
    refspec = paste0("refs/heads/", branch),
    force = force
  )
}

git_branch_pull <- function(branch) {
  repo <- git_repo()
  git2r::fetch(repo, "origin", refspec = branch, verbose = FALSE)
  merge(repo, paste0("origin/", branch), fail = TRUE)
}

git_branch_remote <- function(branch = git_branch_name()) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  upstream <- git2r::branch_get_upstream(branch_obj)
  upstream$name
}

git_branch_track <- function(branch, remote = "origin", remote_branch = branch) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  git2r::branch_set_upstream(branch_obj, paste0(remote, "/", remote_branch))
}

git_branch_delete <- function(branch) {
  branch <- git2r::branches(git_repo(), "local")[[branch]]
  git2r::branch_delete(branch)
}

# Checks ------------------------------------------------------------------

check_uses_git <- function(base_path = proj_get()) {
  if (uses_git(base_path)) {
    return(invisible())
  }

  stop_glue(
    "Cannot detect that project is already a Git repository.\n",
    "Do you need to run {code('use_git()')}?"
  )
}

check_uncommitted_changes <- function(path = proj_get()) {
  if (rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }

  if (uses_git(path) && git_uncommitted(path)) {
    stop_glue("Uncommited changes. Please commit to git before continuing.")
  }
}

git_uncommitted <- function(path = proj_get()) {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

check_branch_not_master <- function() {
  if (git_branch_name() != "master") {
    return()
  }

  stop_glue("
    Currently on master branch.
    Do you need to call {code('pr_init()')} first?
  ")
}

check_branch_current <- function(branch = git_branch_name()) {
  done("Checking that {branch} branch is up to date")
  diff <- git_branch_compare(branch)

  if (diff[[2]] == 0) {
    return()
  }

  stop_glue("
    {branch} branch is out of date.
    Please resolve (somehow) before continuing.
  ")
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

