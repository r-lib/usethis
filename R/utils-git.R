# gert -------------------------------------------------------------------------

gert_shush <- function(expr, regexp) {
  check_character(regexp)
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

  ui_abort(c(
    "Cannot detect that project is already a Git repository.",
    "Do you need to run {.run usethis::use_git()}?"
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

  if (where == "de_facto") {
    return(git_cfg_get(name, "local") %||% git_cfg_get(name, "global"))
  }

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

# more-specific case for user-name and -email
git_user_get <- function(where = c("de_facto", "local", "global")) {
  where <- match.arg(where)

  list(
    name = git_cfg_get("user.name", where),
    email = git_cfg_get("user.email", where)
  )
}

# translate from "usethis" terminology to "git" terminology
where_from_scope <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)

  where_scope <- c(user = "global", project = "de_facto")

  where_scope[scope]
}

# ensures that core.excludesFile is configured
# if configured, leave well enough alone
# if not, check for existence of one of the Usual Suspects; if found, configure
# otherwise, configure as path_home(".gitignore")
ensure_core_excludesFile <- function() {
  path <- git_ignore_path(scope = "user")

  if (!is.null(path)) {
    return(invisible())
  }

  # .gitignore is most common, but .gitignore_global appears in prominent
  # places --> so we allow the latter, but prefer the former
  path <-
    path_first_existing(path_home(c(".gitignore", ".gitignore_global"))) %||%
    path_home(".gitignore")

  if (!is_windows()) {
    # express path relative to user's home directory, except on Windows
    path <- path("~", path_rel(path, path_home()))
  }
  ui_bullets(c(
    "v" = "Configuring {.field core.excludesFile}: {.path {pth(path)}}"
  ))
  gert::git_config_global_set("core.excludesFile", path)
  invisible()
}

# Status------------------------------------------------------------------------
git_status <- function(untracked) {
  check_bool(untracked)
  st <- gert::git_status(repo = git_repo())
  if (!untracked) {
    st <- st[st$status != "new", ]
  }
  st
}

# Commit -----------------------------------------------------------------------
git_ask_commit <- function(message, untracked, push = FALSE, paths = NULL) {
  if (!is_interactive() || !uses_git()) {
    return(invisible())
  }

  # this is defined here to encourage all commits to route through this function
  git_commit <- function(paths, message) {
    repo <- git_repo()
    ui_bullets(c("v" = "Adding files."))
    gert::git_add(paths, repo = repo)
    ui_bullets(c("v" = "Making a commit with message {.val {message}}."))
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
  ui_paths <- usethis_map_cli(paths, template = '{.path {pth("<<x>>")}}')
  file_hint <- "{cli::qty(n)}There {?is/are} {n} uncommitted file{?s}:"
  ui_bullets(c(
    "i" = file_hint,
    bulletize(ui_paths, n_show = 10)
  ))

  # Only push if no remote & a single change
  push <- push && git_can_push(max_local = 1)

  if (
    ui_yep(c(
      "!" = "Is it ok to commit {if (push) 'and push '} {cli::qty(n)} {?it/them}?"
    ))
  ) {
    git_commit(paths, message)
    if (push) {
      git_push()
    }
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
    if (
      ui_yep(c(
        "!" = msg,
        " " = "Do you want to proceed anyway?"
      ))
    ) {
      return(invisible())
    } else {
      ui_abort("Uncommitted changes. Please commit before continuing.")
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

  conflicted_paths <- usethis_map_cli(
    conflicted,
    template = '{.path {pth("<<x>>")}}'
  )
  file_hint <- "{cli::qty(n)}There {?is/are} {n} conflicted file{?s}:"
  ui_bullets(c(
    "i" = file_hint,
    bulletize(conflicted_paths, n_show = 10)
  ))

  yes <- "Yes, open the conflicted files for editing."
  yes_soft <- "Yes, but do not open the conflicted files."
  no <- "No, I want to abort this merge."
  choice <- utils::menu(
    title = "Do you want to proceed with this merge?",
    choices = c(yes, yes_soft, no)
  )

  if (choice < 1 || choice > 2) {
    gert::git_merge_abort(repo = git_repo())
    ui_abort("Abandoning the merge, since it will cause merge conflicts.")
  }

  if (choice == 1) {
    ui_silence(purrr::walk(conflicted, edit_file))
  }
  ui_abort(c(
    "Please fix each conflict, save, stage, and commit.",
    "To back out of this merge, run {.code gert::git_merge_abort()}
     (in R) or {.code git merge --abort} (in the shell)."
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

# Pull -------------------------------------------------------------------------
# Pull from remref or upstream tracking. If neither given/exists, do nothing.
# Therefore, this does less than `git pull`.
git_pull <- function(remref = NULL, verbose = TRUE) {
  check_string(remref, allow_na = TRUE, allow_null = TRUE)
  repo <- git_repo()
  branch <- git_branch()
  remref <- remref %||% git_branch_tracking(branch)
  if (is.na(remref)) {
    if (verbose) {
      ui_bullets(c("v" = "No remote branch to pull from for {.val {branch}}."))
    }
    return(invisible())
  }
  if (verbose) {
    ui_bullets(c("v" = "Pulling from {.val {remref}}."))
  }
  gert::git_fetch(
    remote = remref_remote(remref),
    refspec = remref_branch(remref),
    repo = repo,
    verbose = FALSE
  )
  # this is pretty brittle, because I've hard-wired these messages
  # https://github.com/r-lib/gert/blob/main/R/merge.R
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
    ui_abort("Detached head; can't continue.")
  }
  if (is.na(branch)) {
    ui_abort("On an unborn branch -- do you need to make an initial commit?")
  }
  branch
}

git_branch_tracking <- function(branch = git_branch()) {
  repo <- git_repo()
  if (!gert::git_branch_exists(branch, local = TRUE, repo = repo)) {
    ui_abort("There is no local branch named {.val {branch}}.")
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
  out <- gert::git_ahead_behind(
    upstream = remref,
    ref = branch,
    repo = git_repo()
  )
  list(local_only = out$ahead, remote_only = out$behind)
}

git_can_push <- function(
  max_local = Inf,
  branch = git_branch(),
  remref = NULL
) {
  remref <- remref %||% git_branch_tracking(branch)
  if (is.null(remref)) {
    return(FALSE)
  }
  comp <- git_branch_compare(branch, remref)
  comp$remote_only == 0 && comp$local_only <= max_local
}

git_push <- function(branch = git_branch(), remref = NULL, verbose = TRUE) {
  remref <- remref %||% git_branch_tracking(branch)
  if (verbose) {
    ui_bullets(c(
      "v" = "Pushing local {.val {branch}} branch to {.val {remref}}."
    ))
  }

  gert::git_push(
    remote = remref_remote(remref),
    refspec = glue("refs/heads/{branch}:refs/heads/{remref_branch(remref)}"),
    verbose = FALSE,
    repo = git_repo()
  )
}

git_push_first <- function(
  branch = git_branch(),
  remote = "origin",
  verbose = TRUE
) {
  if (verbose) {
    remref <- glue("{remote}/{branch}")
    ui_bullets(c(
      "v" = "Pushing {.val {branch}} branch to GitHub and setting
             {.val {remref}} as upstream branch."
    ))
  }
  gert::git_push(
    remote = remote,
    set_upstream = TRUE,
    verbose = FALSE,
    repo = git_repo()
  )
}

# Checks ------------------------------------------------------------------

check_current_branch <- function(is = NULL, is_not = NULL, message = NULL) {
  gb <- git_branch()

  if (!is.null(is)) {
    check_string(is)
    if (gb == is) {
      return(invisible())
    } else {
      if (is.null(message)) {
        message <- c("x" = "Must be on branch {.val {is}}, not {.val {gb}}.")
      }
      ui_abort(message)
    }
  }

  if (!is.null(is_not)) {
    check_string(is_not)
    if (gb != is_not) {
      return(invisible())
    } else {
      if (is.null(message)) {
        message <- c("x" = "Can't be on branch {.val {gb}}.")
      }
      ui_abort(message)
    }
  }

  invisible()
}

# examples of remref: upstream/main, origin/foofy
check_branch_up_to_date <- function(
  direction = c("pull", "push"),
  remref = NULL,
  use = NULL
) {
  direction <- match.arg(direction)
  branch <- git_branch()
  remref <- remref %||% git_branch_tracking(branch)
  use <- use %||% switch(direction, pull = "git pull", push = "git push")

  if (is.na(remref)) {
    ui_bullets(c(
      "i" = "Local branch {.val {branch}} is not tracking a remote branch."
    ))
    return(invisible())
  }

  if (direction == "pull") {
    ui_bullets(c(
      "v" = "Checking that local branch {.val {branch}} has the changes
             in {.val {remref}}."
    ))
  } else {
    ui_bullets(c(
      "v" = "Checking that remote branch {.val {remref}} has the changes
             in {.val {branch}}."
    ))
  }

  comparison <- git_branch_compare(branch, remref)

  if (direction == "pull") {
    if (comparison$remote_only == 0) {
      return(invisible())
    } else {
      ui_abort(c(
        "Local branch {.val {branch}} is behind {.val {remref}} by
         {comparison$remote_only} commit{?s}.",
        "Please use {.code {use}} to update."
      ))
    }
  } else {
    if (comparison$local_only == 0) {
      return(invisible())
    } else {
      # TODO: consider offering to push for them?
      ui_abort(c(
        "Local branch {.val {branch}} is ahead of {.val {remref}} by
         {comparison$remote_only} commit{?s}.",
        "Please use {.code {use}} to update."
      ))
    }
  }
}

check_branch_pulled <- function(remref = NULL, use = NULL) {
  check_branch_up_to_date(direction = "pull", remref = remref, use = use)
}

check_branch_pushed <- function(remref = NULL, use = NULL) {
  check_branch_up_to_date(direction = "push", remref = remref, use = use)
}
