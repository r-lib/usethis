git_uncommitted <- function(path = ".") {
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
