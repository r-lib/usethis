# gert -------------------------------------------------------------------------

gert_shush <- function(expr, regexp) {
  stopifnot(is.character(regexp))
  withCallingHandlers(
    gertMessage = function(cnd) {
      m <- map_lgl(regexp, ~ grepl(.x, cnd_message(cnd), perl = TRUE))
      if (any(m)) {
        cnd_muffle(cnd)
      }
    },
    expr
  )
}

# Repository -------------------------------------------------------------------
git_repo <- function() {
  check_uses_git()
  proj_get()
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
  if (where == "global" || !uses_git()) {
    dat <- gert::git_config_global()
  } else {
    dat <- gert::git_config(repo = git_repo())
  }
  if (where == "local") {
    dat <- dat[dat$level == "local", ]
  }
  out <- dat$value[tolower(dat$name) == tolower(name)]
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

  # this is defined here to encourage all commits to route through this function
  git_commit <- function(paths, message) {
    repo <- git_repo()
    ui_done("Adding files")
    gert::git_add(paths, repo = repo)
    ui_done("Making a commit with message {ui_value(message)}")
    gert::git_commit(message, repo = repo)
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
  ui_paths <- map_chr(paths, ui_path)
  if (n > 10) {
    ui_paths <- c(ui_paths[1:10], "...")
  }

  if (n == 1) {
    file_hint <- "There is 1 uncommitted file:"
  } else {
    file_hint <- "There are {n} uncommitted files:"
  }
  ui_line(c(
    file_hint,
    paste0("* ", ui_paths)
  ))

  if (ui_yeah("Is it ok to commit {if (n == 1) 'it' else 'them'}?")) {
    git_commit(paths, message)
  }
  invisible()
}

git_uncommitted <- function(untracked = FALSE) {
  nrow(git_status(untracked)) > 0
}

challenge_uncommitted_changes <- function(untracked = FALSE, msg = NULL) {
  if (!uses_git()) {
    return(invisible())
  }

  if (rstudioapi::hasFun("documentSaveAll")) {
    rstudioapi::documentSaveAll()
  }

  default_msg <- "
    There are uncommitted changes, which may cause problems or be lost when \\
    we push, pull, switch, or compare branches"
  msg <- glue(msg %||% default_msg)
  if (git_uncommitted(untracked = untracked)) {
    if (ui_yeah("{msg}\nDo you want to proceed anyway?")) {
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

  conflicted_paths <- map_chr(conflicted, ui_path)
  ui_line(c(
    "There are {n} conflicted files:",
    paste0("* ", conflicted_paths)
  ))

  msg <- glue("
    Are you ready to sort this out?
    If so, we will open the conflicted files for you to edit.")
  yes <- "Yes, I'm ready to resolve the merge conflicts."
  no <- "No, I want to abort this merge."
  if (ui_yeah(msg, yes = yes, no = no, shuffle = FALSE)) {
    ui_silence(purrr::walk(conflicted, edit_file))
    ui_stop("
      Please fix each conflict, save, stage, and commit.
      To back out of this merge, run {ui_code('gert::git_merge_abort()')} \\
      (in R) or {ui_code('git merge --abort')} (in the shell).")
  } else {
    gert::git_merge_abort(repo = git_repo())
    ui_stop("Abandoning the merge, since it will cause merge conflicts")
  }
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

# Pull -------------------------------------------------------------------------
# Pull from remref or upstream tracking. If neither given/exists, do nothing.
# Therefore, this does less than `git pull`.
git_pull <- function(remref = NULL, verbose = TRUE) {
  repo <- git_repo()
  branch <- git_branch()
  remref <- remref %||% git_branch_tracking(branch)
  if (is.na(remref)) {
    if (verbose) {
      ui_done("No remote branch to pull from for {ui_value(branch)}")
    }
    return(invisible())
  }
  stopifnot(is_string(remref))
  if (verbose) {
    ui_done("Pulling from {ui_value(remref)}")
  }
  gert::git_fetch(
    remote = remref_remote(remref),
    refspec = remref_branch(remref),
    repo = repo,
    verbose = FALSE
  )
  # this is pretty brittle, because I've hard-wired these messages
  # https://github.com/r-lib/gert/blob/master/R/merge.R
  # but at time of writing, git_merge() offers no verbosity control
  gert_shush(
    regexp = c(
      "Already up to date, nothing to merge",
      "Performing fast-forward merge, no commit needed"
    ),
    gert::git_merge(remref, repo = repo)
  )
  st <- git_status(untracked = TRUE)
  if (any(st$status == "conflicted")) {
    git_conflict_report()
  }

  invisible()
}

# Branch ------------------------------------------------------------------
git_branch <- function() {
  info <- gert::git_info(repo = git_repo())
  branch <- info$shorthand
  if (identical(branch, "HEAD")) {
    ui_stop("Detached head; can't continue")
  }
  if (is.na(branch)) {
    ui_stop("On an unborn branch -- do you need to make an initial commit?")
  }
  branch
}

git_branch_tracking <- function(branch = git_branch()) {
  repo <- git_repo()
  if (!gert::git_branch_exists(branch, local = TRUE, repo = repo)) {
    ui_stop("There is no local branch named {ui_value(branch)}")
  }
  gbl <- gert::git_branch_list(local = TRUE, repo = repo)
  sub("^refs/remotes/", "", gbl$upstream[gbl$name == branch])
}

git_branch_compare <- function(branch = git_branch(), remref = NULL) {
  remref <- remref %||% git_branch_tracking(branch)
  gert::git_fetch(
    remote = remref_remote(remref),
    refspec = remref_branch(remref),
    repo = git_repo(),
    verbose = FALSE
  )
  out <- gert::git_ahead_behind(upstream = remref, ref = branch, repo = git_repo())
  list(local_only = out$ahead, remote_only = out$behind)
}

# Checks ------------------------------------------------------------------
check_default_branch <- function() {
  default_branch <- git_branch_default()
  ui_done("
    Checking that current branch is default branch ({ui_value(default_branch)})")
  actual <- git_branch()
  if (actual == default_branch) {
    return(invisible())
  }
  ui_stop("
    Must be on branch {ui_value(default_branch)}, not {ui_value(actual)}.")
}

challenge_non_default_branch <- function(details = "Are you sure you want to proceed?") {
  actual <- git_branch()
  default_branch <- git_branch_default()
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

# examples of remref: upstream/master, origin/foofy
check_branch_up_to_date <- function(direction = c("pull", "push"),
                                    remref = NULL,
                                    use = NULL) {
  direction <- match.arg(direction)
  branch <- git_branch()
  remref <- remref %||% git_branch_tracking(branch)
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
      # TODO: consider offering to push for them?
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
  check_branch_up_to_date(direction = "push", remref = remref, use = use)
}
