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

#' Determine default Git branch
#'
#' Figure out the default branch of the current Git repo.
#'
#' @return A branch name
#' @export
#'
#' @examples
#' \dontrun{
#' git_branch_default()
#' }
git_branch_default <- function() {
  check_uses_git()
  repo <- git_repo()

  gb <- gert::git_branch_list(local = TRUE, repo = repo)[["name"]]
  if (length(gb) == 1) {
    return(gb)
  }

  # Check the most common names used for the default branch
  gb <- set_names(gb)
  usual_suspects_branchname <- c("main", "master", "default")
  branch_candidates <- purrr::discard(gb[usual_suspects_branchname], is.na)

  if (length(branch_candidates) == 1) {
    return(branch_candidates[[1]])
  }
  # either 0 or >=2 of the usual suspects are present

  # Can we learn what HEAD points to on a relevant Git remote?
  gr <- git_remotes()
  usual_suspects_remote <- c("upstream", "origin")
  gr <- purrr::compact(gr[usual_suspects_remote])

  if (length(gr)) {
    remote_names <- set_names(names(gr))

    # check symbolic ref, e.g. refs/remotes/origin/HEAD (a local operation)
    remote_heads <- map(
      remote_names,
      ~ gert::git_remote_info(.x, repo = repo)$head
    )
    remote_heads <- purrr::compact(remote_heads)
    if (length(remote_heads)) {
      return(path_file(remote_heads[[1]]))
    }

    # ask the remote (a remote operation)
    f <- function(x) {
      dat <- gert::git_remote_ls(remote = x, verbose = FALSE, repo = repo)
      path_file(dat$symref[dat$ref == "HEAD"])
    }
    f <- purrr::possibly(f, otherwise = NULL)
    remote_heads <- purrr::compact(map(remote_names, f))
    if (length(remote_heads)) {
      return(remote_heads[[1]])
    }
  }
  # no luck consulting usual suspects re: Git remotes
  # go back to locally configured branches

  # Is init.defaultBranch configured?
  # https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch
  init_default_branch <- git_cfg_get("init.defaultBranch")
  if ((!is.null(init_default_branch)) && (init_default_branch %in% gb)) {
    return(init_default_branch)
  }

  # take first existing branch from usual suspects
  if (length(branch_candidates)) {
    return(branch_candidates[[1]])
  }

  # take first existing branch
  if (length(gb)) {
    return(gb[[1]])
  }

  # I think this means we are on an unborn branch
  ui_stop("
    Can't determine the default branch for this repo
    Do you need to make your first commit?")
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
  stopifnot(is_string(name))
  stopifnot(is.null(url) || is_string(url))
  stopifnot(is_true(overwrite) || is_false(overwrite))

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
#' diagnosing problems. [git_vaccinate()] adds some basic R- and RStudio-related
#' entries to the user-level git ignore file.
#' @export
#' @examples
#' \dontrun{
#' git_sitrep()
#' }
git_sitrep <- function() {
  ui_silence(try(proj_get(), silent = TRUE))

  # git (global / user) --------------------------------------------------------
  hd_line("Git config (global)")
  kv_line("Name", git_cfg_get("user.name", "global"))
  kv_line("Email", git_cfg_get("user.email", "global"))
  vaccinated <- git_vaccinated()
  kv_line("Vaccinated", vaccinated)
  if (!vaccinated) {
    ui_info("See {ui_code('?git_vaccinate')} to learn more")
  }
  kv_line("Default Git protocol", git_protocol())

  # github (global / user) -----------------------------------------------------
  hd_line("GitHub")
  default_gh_host <- get_hosturl(default_api_url())
  kv_line("Default GitHub host", default_gh_host)
  pat_sitrep(default_gh_host)

  # git and github for active project ------------------------------------------
  hd_line("Git repo for current project")

  if (!proj_active()) {
    ui_info("No active usethis project")
    return(invisible())
  }
  kv_line("Active usethis project", proj_get())
  if (!uses_git()) {
    ui_info("Active project is not a Git repo")
    return(invisible())
  }

  # local git config -----------------------------------------------------------
  if (proj_active() && uses_git()) {
    local_user <- list(
      user.name = git_cfg_get("user.name", "local"),
      user.email = git_cfg_get("user.email", "local")
    )
    if (!is.null(local_user$user.name) || !is.null(local_user$user.name)) {
      ui_info("This repo has a locally configured user")
      kv_line("Name", local_user$user.name)
      kv_line("Email", local_user$user.email)
    }
  }

  # default branch -------------------------------------------------------------
  kv_line("Default branch", git_branch_default())

  # current branch -------------------------------------------------------------
  branch <- tryCatch(git_branch(), error = function(e) NULL)
  tracking_branch <- if (is.null(branch)) NA_character_ else git_branch_tracking()
  # TODO: can't really express with kv_line() helper
  branch <- if (is.null(branch)) "<unset>" else branch
  tracking_branch <- if (is.na(tracking_branch)) "<unset>" else tracking_branch
  # vertical alignment would make this nicer, but probably not worth it
  ui_bullet(glue("
    Current local branch -> remote tracking branch:
    {ui_value(branch)} -> {ui_value(tracking_branch)}"))

  # GitHub remote config -------------------------------------------------------
  cfg <- github_remote_config()
  repo_host <- cfg$host_url
  if (!is.na(repo_host) && repo_host != default_gh_host) {
    kv_line("Non-default GitHub host", repo_host)
    pat_sitrep(repo_host)
  }

  hd_line("GitHub remote configuration")
  purrr::walk(format(cfg), ui_bullet)
  invisible()
}

pat_sitrep <- function(host = "https://github.com") {
  pat <- gh::gh_token(api_url = host)
  have_pat <- pat != ""
  if (!have_pat) {
    kv_line("Personal access token for {ui_value(host)}", NULL)
    ui_oops("
      Call {ui_code('gh_token_help()')} for help configuring a token")
    return(FALSE)
  }

  kv_line("Personal access token for {ui_value(host)}", "<discovered>")
  tryCatch(
    {
      who <- gh::gh_whoami(.token = pat, .api_url = host)
      kv_line("GitHub user", who$login)
      scopes <- who$scopes
      kv_line("Token scopes", who$scopes)
      # https://docs.github.com/en/free-pro-team@latest/developers/apps/scopes-for-oauth-apps
      # why these checks?
      # previous defaults for create_github_token(): repo, gist, user:email
      # more recently: repo, user, gist, workflow
      # (gist scope is a very weak recommendation)
      scopes <- strsplit(scopes, ", ")[[1]]
      if (length(scopes) == 0 ||
          !any(grepl("^repo$", scopes)) ||
          !any(grepl("^workflow$", scopes)) ||
          !any(grepl("^user(:email)?$", scopes))) {
        ui_oops("
            Token may be mis-scoped: {ui_value('repo')} and \\
            {ui_value('user')} are highly recommended scopes
            The {ui_value('workflow')} scope is needed to manage GitHub \\
            Actions workflow files
            If you are troubleshooting, consider this")
      }
    },
    http_error_401 = function(e) ui_oops("Token is invalid"),
    error = function(e) {
      ui_oops("
        Can't get user profile for this token. Is the network reachable?")
    }
  )
  tryCatch(
    {
      emails <- gh::gh("/user/emails", .token = pat, .api_url = host)
      addresses <- map_chr(
        emails,
        ~ if (.x$primary) glue_data(.x, "{email} (primary)") else .x[["email"]]
      )
      kv_line("Email(s)", addresses)
      de_facto_email <- git_cfg_get("user.email", "de_facto")
      if (!any(grepl(de_facto_email, addresses))) {
        ui_oops("
          User's Git email ({ui_value(de_facto_email)}) doesn't appear to be \\
          registered with GitHub")
      }
    },
    error = function(e) {
      ui_oops("
        Can't retrieve registered email address(es)
        If you are troubleshooting, check GitHub host, token, and token scopes")
    }
  )
  TRUE
}

# Vaccination -------------------------------------------------------------

#' Vaccinate your global gitignore file
#'
#' Adds `.DS_Store`, `.Rproj.user`, `.Rdata`, `.Rhistory`, and `.httr-oauth` to
#' your global (a.k.a. user-level) `.gitignore`. This is good practice as it
#' decreases the chance that you will accidentally leak credentials to GitHub.
#'
#' @export
git_vaccinate <- function() {
  path <- git_ignore_path("user")
  write_union(path, git_ignore_lines)
}

git_vaccinated <- function() {
  path <- git_ignore_path("user")
  if (!file_exists(path)) {
    return(FALSE)
  }

  lines <- read_utf8(path)
  all(git_ignore_lines %in% lines)
}

git_ignore_lines <- c(
  ".Rproj.user",
  ".Rhistory",
  ".Rdata",
  ".httr-oauth",
  ".DS_Store"
)
