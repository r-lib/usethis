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
    gert::git_config()
  )
  if (where == "local") {
    dat <- dat[dat$level == "local", ]
  }
  out <- dat$value[dat$name == name]
  if (length(out) > 0) out else NULL
}
