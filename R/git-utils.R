git_uncommitted <- function(path = proj_get()) {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

check_uncommitted_changes <- function(path = proj_get()) {
  if (uses_git(path) && git_uncommitted(path)) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }
}

github_owner <- function(path = proj_get()) {
  gh::gh_tree_remote(path)[["username"]]
}

github_repo <- function(path = proj_get()) {
  gh::gh_tree_remote(path)[["repo"]]
}
