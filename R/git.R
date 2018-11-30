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
  if (uses_git()) {
    return(invisible())
  }

  done("Initialising Git repo")
  r <- git_init()

  use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))

  if (interactive() && git_uncommitted()) {
    paths <- sort(unlist(git2r::status(r)))
    bullets <- glue("* {value(paths)}")

    commit_consent_msg <- glue("
      OK to make an initial commit of {length(paths)} files?
      {bullets}"
    )
    if (yep(commit_consent_msg)) {
      done("Adding files and committing")
      git2r::add(r, paths)
      git2r::commit(r, message)
    }
  }

  restart_rstudio(
    "A restart of RStudio is required to activate the Git pane"
  )
  invisible(TRUE)

}

#' Add a git hook
#'
#' Sets up a git hook using specified script. Creates hook directory if
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

  hook_dir <- create_directory(proj_get(), ".git/hooks")
  hook_path <- path(hook_dir, hook)
  write_over(hook_path, script)
  file_chmod(hook_path, "0744")

  invisible()
}

#' Tell git to ignore files
#'
#' @param ignores Character vector of ignores, specified as file globs.
#' @param directory Directory relative to active project to set ignores
#' @family git helpers
#' @export
use_git_ignore <- function(ignores, directory = ".") {
  write_union(proj_path(directory, ".gitignore"), ignores)
}

#' Configure Git
#'
#' Sets Git options, for either the user or the project ("global" or "local", in
#' Git terminology). The mandate is currently very narrow: to manage the user
#' name and email. The `scope` argument is consulted when writing. When reading,
#' `use_git_config()` ignores `scope` and simply reports the options in effect,
#' where local config overrides global, if present. Use [git2r::config()]
#' directly or the command line for general Git configuration.
#'
#' @param ... Name-value pairs.
#' @return Invisibly, the previous values of the modified components.
#' @inheritParams edit
#'
#' @family git helpers
#' @export
#' @examples
#' \dontrun{
#' git_sitrep()
#'
#' ## set the user's global user.name and user.email
#' use_git_config(user.name = "Jane", user.email = "jane@example.org")
#'
#' ## set the user.name and user.email locally, i.e. for current repo/project
#' use_git_config(
#'   scope = "project",
#'   user.name = "Jane",
#'   user.email = "jane@example.org"
#' )
#' }
use_git_config <- function(scope = c("user", "project"), ...) {
  scope <- match.arg(scope)

  if (scope == "user") {
    git_config(...)
  } else {
    check_uses_git()
    git_config(..., .repo = git_repo())
  }
}

git_check_in <- function(base_path, paths, message) {
  if (!uses_git(base_path))
    return(invisible())

  if (!git_uncommitted(base_path))
    return(invisible())

  done("Checking into git [{message}]")

  r <- git2r::repository(base_path)
  git2r::add(r, paths)
  git2r::commit(r, message)

  invisible(TRUE)
}

#' git/GitHub sitrep
#'
#' Get a situation report on your current git/GitHub status. Useful for
#' diagnosing problems
#'
#' @export
#' @examples
#' git_sitrep()
git_sitrep <- function() {
  name <- git_config_get("user.name", global = TRUE)
  email <- git_config_get("user.email", global = TRUE)

  hd_line <- function(name) {
    cat_line(crayon::bold(name))
  }
  kv_line <- function(key, value) {
    if (is.null(value)) {
      value <- crayon::red("<unset>")
    } else {
      value <- value(value)
    }
    cat_line("* ", field(key), ": ", value)
  }

  hd_line("User")
  kv_line("Name", name)
  kv_line("Email", email)
  kv_line("Has SSH keys", git_has_ssh())
  kv_line("Vaccinated: ", git_vaccinated())

  hd_line("git2r")
  kv_line("Supports SSH", git2r::libgit2_features()$ssh)

  if (proj_active()) {
    hd_line("Project")
    if (uses_git()) {
      repo <- git_repo()
      kv_line("Path", repo$path)
      kv_line("Branch", git_branch_name())
      kv_line("Remote", git_branch_remote())
    } else {
      cat_line("Git not activated")
    }
  }

  hd_line("GitHub")
  if (!nzchar(gh_token())) {
    cat_line("No token available")
  } else {
    who <- gh::gh_whoami()
    kv_line("User", who$login)
    kv_line("Name", who$name)
  }
}


# Vaccination -------------------------------------------------------------

#' Vaccinate your global git ignore
#'
#' Adds `.DS_Store`, `.Rproj.user`, and `.Rhistory` to your global
#' `.gitignore`. This is good practices as it ensures that you will never
#' accidentally leak credentials to GitHub.
#'
#' @export
git_vaccinate <- function() {
  path <- git_ignore_path("user")
  write_union(path, git_global_ignore)
}

git_vaccinated <- function() {
  path <- git_ignore_path("user")
  if (!file_exists(path)) {
    return(FALSE)
  }

  lines <- readLines(path)
  all(git_global_ignore %in% lines)
}

git_global_ignore <- c(
  ".Rproj.user",
  ".Rhistory",
  ".Rdata",
  ".DS_Store"
)

