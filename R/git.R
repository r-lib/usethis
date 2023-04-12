#' Initialise a git repository
#'
#' `use_git()` initialises a Git repository and adds important files to
#' `.gitignore`. If user consents, it also makes an initial commit.
#'
#' @param message Message to use for first commit.
#' @family git helpers
#' @export
#' @examples
#' \dontrun{
#' use_git()
#' }
use_git <- function(message = "Initial commit") {
  needs_init <- !uses_git()
  if (needs_init) {
    ui_done("Initialising Git repo")
    git_init()
  }

  use_git_ignore(git_ignore_lines)
  if (git_uncommitted(untracked = TRUE)) {
    git_ask_commit(message, untracked = TRUE)
  }

  if (needs_init) {
    restart_rstudio("A restart of RStudio is required to activate the Git pane")
  }

  invisible(TRUE)
}

#' Add a git hook
#'
#' Sets up a git hook using the specified script. Creates a hook directory if
#' needed, and sets correct permissions on hook.
#'
#' @param hook Hook name. One of "pre-commit", "prepare-commit-msg",
#'   "commit-msg", "post-commit", "applypatch-msg", "pre-applypatch",
#'   "post-applypatch", "pre-rebase", "post-rewrite", "post-checkout",
#'   "post-merge", "pre-push", "pre-auto-gc".
#' @param script Text of script to run
#' @family git helpers
#' @export
use_git_hook <- function(hook, script) {
  check_uses_git()

  hook_path <- proj_path(".git", "hooks", hook)
  create_directory(path_dir(hook_path))

  write_over(hook_path, script)
  file_chmod(hook_path, "0744")

  invisible()
}

#' Tell Git to ignore files
#'
#' @param ignores Character vector of ignores, specified as file globs.
#' @param directory Directory relative to active project to set ignores
#' @family git helpers
#' @export
use_git_ignore <- function(ignores, directory = ".") {
  write_union(proj_path(directory, ".gitignore"), ignores)
  rstudio_git_tickle()
}

#' Configure Git
#'
#' Sets Git options, for either the user or the project ("global" or "local", in
#' Git terminology). Wraps [gert::git_config_set()] and
#' [gert::git_config_global_set()]. To inspect Git config, see
#' [gert::git_config()].
#'
#' @param ... Name-value pairs, processed as
#'   <[`dynamic-dots`][rlang::dyn-dots]>.
#'
#' @return Invisibly, the previous values of the modified components, as a named
#'   list.
#' @inheritParams edit
#'
#' @family git helpers
#' @export
#' @examples
#' \dontrun{
#' # set the user's global user.name and user.email
#' use_git_config(user.name = "Jane", user.email = "jane@example.org")
#'
#' # set the user.name and user.email locally, i.e. for current repo/project
#' use_git_config(
#'   scope = "project",
#'   user.name = "Jane",
#'   user.email = "jane@example.org"
#' )
#' }
use_git_config <- function(scope = c("user", "project"), ...) {
  scope <- match.arg(scope)

  dots <- list2(...)
  stopifnot(is_dictionaryish(dots))

  orig <- stats::setNames(
    vector(mode = "list", length = length(dots)),
    names(dots)
  )
  for (i in seq_along(dots)) {
    nm <- names(dots)[[i]]
    vl <- dots[[i]]
    if (scope == "user") {
      orig[nm] <- git_cfg_get(nm, "global") %||% list(NULL)
      gert::git_config_global_set(nm, vl)
    } else {
      check_uses_git()
      orig[nm] <- git_cfg_get(nm, "local") %||% list(NULL)
      gert::git_config_set(nm, vl, repo = git_repo())
    }
  }

  invisible(orig)
}

#' See or set the default Git protocol
#'
#' @description
#' Git operations that address a remote use a so-called "transport protocol".
#' usethis supports HTTPS and SSH. The protocol dictates the Git URL format used
#' when usethis needs to configure the first GitHub remote for a repo:
#' * `protocol = "https"` implies `https://github.com/<OWNER>/<REPO>.git`
#' * `protocol = "ssh"` implies `git@@github.com:<OWNER>/<REPO>.git`
#'
#' Two helper functions are available:
#'   * `git_protocol()` reveals the protocol "in force". As of usethis v2.0.0,
#'     this defaults to "https". You can change this for the duration of the
#'     R session with `use_git_protocol()`. Change the default for all R
#'     sessions with code like this in your `.Rprofile` (easily editable via
#'     [edit_r_profile()]):
#'     ```
#'     options(usethis.protocol = "ssh")
#'     ```
#'   * `use_git_protocol()` sets the Git protocol for the current R session
#'
#' This protocol only affects the Git URL for newly configured remotes. All
#' existing Git remote URLs are always respected, whether HTTPS or SSH.
#'
#' @param protocol One of "https" or "ssh"
#'
#' @return The protocol, either "https" or "ssh"
#' @export
#'
#' @examples
#' \dontrun{
#' git_protocol()
#'
#' use_git_protocol("ssh")
#' git_protocol()
#'
#' use_git_protocol("https")
#' git_protocol()
#' }
git_protocol <- function() {
  protocol <- tolower(getOption("usethis.protocol", "unset"))
  if (identical(protocol, "unset")) {
    ui_info("Defaulting to {ui_value('https')} Git protocol")
    protocol <- "https"
  } else {
    check_protocol(protocol)
  }
  options("usethis.protocol" = protocol)
  getOption("usethis.protocol")
}

#' @rdname git_protocol
#' @export
use_git_protocol <- function(protocol) {
  options("usethis.protocol" = protocol)
  invisible(git_protocol())
}

check_protocol <- function(protocol) {
  if (!is_string(protocol) ||
      !(tolower(protocol) %in% c("https", "ssh"))) {
    options(usethis.protocol = NULL)
    ui_stop("
      {ui_code('protocol')} must be either {ui_value('https')} or \\
      {ui_value('ssh')}")
  }
  invisible()
}

#' Configure and report Git remotes
#'
#' Two helpers are available:
#'   * `use_git_remote()` sets the remote associated with `name` to `url`.
#'   * `git_remotes()` reports the configured remotes, similar to
#'     `git remote -v`.
#'
#' @param name A string giving the short name of a remote.
#' @param url A string giving the url of a remote.
#' @param overwrite Logical. Controls whether an existing remote can be
#'   modified.
#'
#' @return Named list of Git remotes.
#' @export
#'
#' @examples
#' \dontrun{
#' # see current remotes
#' git_remotes()
#'
#' # add new remote named 'foo', a la `git remote add <name> <url>`
#' use_git_remote(name = "foo", url = "https://github.com/<OWNER>/<REPO>.git")
#'
#' # remove existing 'foo' remote, a la `git remote remove <name>`
#' use_git_remote(name = "foo", url = NULL, overwrite = TRUE)
#'
#' # change URL of remote 'foo', a la `git remote set-url <name> <newurl>`
#' use_git_remote(
#'   name = "foo",
#'   url = "https://github.com/<OWNER>/<REPO>.git",
#'   overwrite = TRUE
#' )
#'
#' # Scenario: Fix remotes when you cloned someone's repo, but you should
#' # have fork-and-cloned (in order to make a pull request).
#'
#' # Store origin = main repo's URL, e.g., "git@github.com:<OWNER>/<REPO>.git"
#' upstream_url <- git_remotes()[["origin"]]
#'
#' # IN THE BROWSER: fork the main GitHub repo and get your fork's remote URL
#' my_url <- "git@github.com:<ME>/<REPO>.git"
#'
#' # Rotate the remotes
#' use_git_remote(name = "origin", url = my_url)
#' use_git_remote(name = "upstream", url = upstream_url)
#' git_remotes()
#'
#' # Scenario: Add upstream remote to a repo that you fork-and-cloned, so you
#' # can pull upstream changes.
#' # Note: If you fork-and-clone via `usethis::create_from_github()`, this is
#' # done automatically!
#'
#' # Get URL of main GitHub repo, probably in the browser
#' upstream_url <- "git@github.com:<OWNER>/<REPO>.git"
#' use_git_remote(name = "upstream", url = upstream_url)
#' }
use_git_remote <- function(name = "origin", url, overwrite = FALSE) {
  check_name(name)
  maybe_name(url)
  check_bool(overwrite)

  remotes <- git_remotes()
  repo <- git_repo()

  if (name %in% names(remotes) && !overwrite) {
    ui_stop("
      Remote {ui_value(name)} already exists. Use \\
      {ui_code('overwrite = TRUE')} to edit it anyway.")
  }

  if (name %in% names(remotes)) {
    if (is.null(url)) {
      gert::git_remote_remove(remote = name, repo = repo)
    } else {
      gert::git_remote_set_url(url = url, remote = name, repo = repo)
    }
  } else if (!is.null(url)) {
    gert::git_remote_add(url = url, name = name, repo = repo)
  }

  invisible(git_remotes())
}

#' @rdname use_git_remote
#' @export
git_remotes <- function() {
  x <- gert::git_remote_list(repo = git_repo())
  if (nrow(x) == 0) {
    return(NULL)
  }
  stats::setNames(as.list(x$url), x$name)
}

# unexported function to improve my personal quality of life
git_clean <- function() {
  if (!is_interactive() || !uses_git()) {
    return(invisible())
  }

  st <- gert::git_status(staged = FALSE, repo = git_repo())
  paths <- st[st$status == "new", ][["file"]]
  n <- length(paths)
  if (n == 0) {
    ui_info("Found no untracked files")
    return(invisible())
  }

  paths <- sort(paths)
  ui_paths <- map_chr(paths, ui_path)
  if (n > 10) {
    ui_paths <- c(ui_paths[1:10], "...")
  }

  if (n == 1) {
    file_hint <- "There is 1 untracked file:"
  } else {
    file_hint <- "There are {n} untracked files:"
  }
  ui_line(c(
    file_hint,
    paste0("* ", ui_paths)
  ))

  if (ui_yeah("

    Do you want to remove {if (n == 1) 'it' else 'them'}?",
    yes = "yes", no = "no", shuffle = FALSE)) {
    file_delete(paths)
    ui_done("{n} file(s) deleted")
  }
  rstudio_git_tickle()
  invisible()
}

#' Git/GitHub sitrep
#'
#' Get a situation report on your current Git/GitHub status. Useful for
#' diagnosing problems. The default is to report all values; provide values
#' for `tool` or `scope` to be more specific.
#'
#' @param tool Report for __git__, or __github__
#' @param scope Report globally for the current __user__, or locally for the
#'   current __project__
#'
#' @export
#' @examples
#' \dontrun{
#' # report all
#' git_sitrep()
#'
#' # report git for current user
#' git_sitrep("git", "user")
#' }
git_sitrep <- function(tool = c("git", "github"),
                       scope = c("user", "project")) {

  tool <- rlang::arg_match(tool, multiple = TRUE)
  scope <- rlang::arg_match(scope, multiple = TRUE)

  ui_silence(try(proj_get(), silent = TRUE))

  # git (global / user) --------------------------------------------------------
  init_default_branch <- git_cfg_get("init.defaultBranch", where = "global")
  if ("git" %in% tool && "user" %in% scope) {
    cli::cli_h3("Git global (user)")
    git_user_sitrep("user")
    kv_line("Global (user-level) gitignore file", git_ignore_path("user"))
    vaccinated <- git_vaccinated()
    kv_line("Vaccinated", vaccinated)
    if (!vaccinated) {
      ui_info("See {ui_code('?git_vaccinate')} to learn more")
    }
    kv_line("Default Git protocol", git_protocol())
    kv_line("Default initial branch name", init_default_branch)
  }

  # github (global / user) -----------------------------------------------------
  default_gh_host <- get_hosturl(default_api_url())
  if ("github" %in% tool && "user" %in% scope) {
    cli::cli_h3("GitHub user")
    kv_line("Default GitHub host", default_gh_host)
    pat_sitrep(default_gh_host, scope = "user")
  }

  # git and github for active project ------------------------------------------
  if (!"project" %in% scope) {
    return(invisible())
  }

  if (!proj_active()) {
    ui_info("No active usethis project")
    return(invisible())
  }
  cli::cli_h2(glue("Active usethis project: {ui_value(proj_get())}"))

  if (!uses_git()) {
    ui_info("Active project is not a Git repo")
    return(invisible())
  }

  # current branch -------------------------------------------------------------
  branch <- tryCatch(git_branch(), error = function(e) NULL)
  tracking_branch <- if (is.null(branch)) NA_character_ else git_branch_tracking()
  # TODO: can't really express with kv_line() helper
  branch <- if (is.null(branch)) "<unset>" else branch
  tracking_branch <- if (is.na(tracking_branch)) "<unset>" else tracking_branch

  # local git config -----------------------------------------------------------
  if ("git" %in% tool) {
    cli::cli_h3("Git local (project)")
    git_user_sitrep("project")

    # default branch -------------------------------------------------------------
    default_branch_sitrep()

    # vertical alignment would make this nicer, but probably not worth it
    ui_bullet(glue("
      Current local branch -> remote tracking branch:
      {ui_value(branch)} -> {ui_value(tracking_branch)}"))
  }

  # GitHub remote config -------------------------------------------------------
  if ("github" %in% tool) {
    cli::cli_h3("GitHub project")

    cfg <- github_remote_config()

    if (cfg$type == "no_github") {
      ui_info("Project does not use GitHub")
      return(invisible())
    }

    repo_host <- cfg$host_url
    if (!is.na(repo_host) && repo_host != default_gh_host) {
      cli::cli_text("Host:")
      kv_line("Non-default GitHub host", repo_host)
      pat_sitrep(repo_host, scope = "project", scold_for_renviron = FALSE)
      cli::cli_text("Project:")
    }

    purrr::walk(format(cfg), ui_bullet)
  }

  invisible()
}

git_user_sitrep <- function(scope = c("user", "project")) {
  scope <- rlang::arg_match(scope)

  where <- where_from_scope(scope)

  user <- git_user_get(where)
  user_local <- git_user_get("local")

  if (scope == "project" && !all(map_lgl(user_local, is.null))) {
    ui_info("This repo has a locally configured user")
  }

  kv_line("Name", user$name)
  kv_line("Email", user$email)

  git_user_check(user)

  invisible(NULL)
}

git_user_check <- function(user) {
  if (all(map_lgl(user, is.null))) {
    hint <-
      'use_git_config(user.name = "<your name>", user.email = "<your email>")'
    ui_oops(
      "Git user's name and email are not set. Configure using {ui_code(hint)}."
    )
    return(invisible(NULL))
  }

  if (is.null(user$name)) {
    hint <- 'use_git_config(user.name = "<your name>")'
    ui_oops("Git user's name is not set. Configure using {ui_code(hint)}.")
  }

  if (is.null(user$email)) {
    hint <- 'use_git_config(user.email = "<your email>")'
    ui_oops("Git user's email is not set. Configure using {ui_code(hint)}.")
  }
}

# TODO: when I really overhaul the UI, determine if I can just re-use the
# git_default_branch() error messages in the sitrep
# the main point is converting an error to an "oops" type of message
default_branch_sitrep <- function() {
  tryCatch(
    kv_line("Default branch", git_default_branch()),
    error_default_branch = function(e) {
      if (has_name(e, "db_local")) {
        # FYI existence of db_local implies existence of db_source
        ui_oops("
          Default branch mismatch between local repo and remote!
          {ui_value(e$db_source$name)} remote default branch: \\
          {ui_value(e$db_source$default_branch)}
          Local default branch: {ui_value(e$db_local)}
          Call {ui_code('git_default_branch_rediscover()')} to resolve this.")
      } else if (has_name(e, "db_source")) {
        ui_oops("
          Default branch mismatch between local repo and remote!
          {ui_value(e$db_source$name)} remote default branch: \\
          {ui_value(e$db_source$default_branch)}
          Local repo has no branch by that name nor any other obvious candidates.
          Call {ui_code('git_default_branch_rediscover()')} to resolve this.")
      } else {
        ui_oops("Default branch cannot be determined.")
      }
    }
  )
}

# Vaccination -------------------------------------------------------------

#' Vaccinate your global gitignore file
#'
#' Adds `.DS_Store`, `.Rproj.user`, `.Rdata`, `.Rhistory`, and `.httr-oauth` to
#' your global (a.k.a. user-level) `.gitignore`. This is good practice as it
#' decreases the chance that you will accidentally leak credentials to GitHub.
#' `git_vaccinate()` also tries to detect and fix the situation where you have a
#' global gitignore file, but it's missing from your global Git config.
#'
#' @export
git_vaccinate <- function() {
  ensure_core_excludesFile()
  path <- git_ignore_path(scope = "user")
  if (!file_exists(path)) {
    ui_done("Creating the global (user-level) gitignore: {ui_path(path)}")
  }
  write_union(path, git_ignore_lines)
}

git_vaccinated <- function() {
  path <- git_ignore_path("user")
  if (is.null(path) || !file_exists(path)) {
    return(FALSE)
  }
  # on Windows, if ~/ is present, take care to expand it the fs way
  lines <- read_utf8(user_path_prep(path))
  all(git_ignore_lines %in% lines)
}

git_ignore_lines <- c(
  ".Rproj.user",
  ".Rhistory",
  ".Rdata",
  ".httr-oauth",
  ".DS_Store"
)
