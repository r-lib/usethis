uses_git <- function(path = proj_get()) {
  repo <- tryCatch(
    gert::git_find(path),
    error = function(e) NULL
  )
  !is.null(repo)
}

check_uses_git <- function(path = proj_get()) {
  if (uses_git(path)) {
    return(invisible())
  }

  ui_stop(c(
    "Cannot detect that project is already a Git repository.",
    "Do you need to run {ui_code('use_git()')}?"
  ))
}

# TODO: presumably this becomes git_repo() once the switchover is complete
gert_repo <- function() {
  check_uses_git()
  gert::git_find(proj_get())
}
