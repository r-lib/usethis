#' Create a package or project
#'
#' @description
#' These functions create an R project:
#'   * `create_package()` creates an R package.
#'   * `create_project()` creates a non-package project, i.e. a data analysis
#'     project.
#'   * `create_quarto_project()` creates a Quarto project. It is a simplified
#'     convenience wrapper around [quarto::quarto_create_project()], which you
#'     should call directly for more advanced usage.
#'
#' These functions can be called on an existing project; you will be asked
#' before any existing files are changed.
#'
#' @inheritParams use_description
#' @param fields A named list of fields to add to `DESCRIPTION`, potentially
#'   overriding default values. See [use_description()] for how you can set
#'   personalized defaults using package options.
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param roxygen Do you plan to use roxygen2 to document your package?
#' @param rstudio If `TRUE`, calls [use_rstudio()] to make the new package or
#'   project into an [RStudio
#'   Project](https://r-pkgs.org/workflow101.html#sec-workflow101-rstudio-projects).
#'    If `FALSE` and a non-package project, a sentinel `.here` file is placed so
#'   that the directory can be recognized as a project by the
#'   [here](https://here.r-lib.org) or
#'   [rprojroot](https://rprojroot.r-lib.org) packages.
#' @param open If `TRUE`, [activates][proj_activate()] the new project:
#'
#'   * If using RStudio desktop, the package is opened in a new session.
#'   * If on RStudio server, the current RStudio project is activated.
#'   * Otherwise, the working directory and active project is changed.
#' @returns Path to the newly created project or package,
#'   invisibly.
#' @seealso [create_tidy_package()] is a convenience function that extends
#'   `create_package()` by immediately applying as many of the tidyverse
#'   development conventions as possible.
#' @export
create_package <- function(path,
                           fields = list(),
                           rstudio = rstudioapi::isAvailable(),
                           roxygen = TRUE,
                           check_name = TRUE,
                           open = rlang::is_interactive()) {
  path <- user_path_prep(path)
  check_path_is_directory(path_dir(path))

  name <- path_file(path_abs(path))
  if (check_name) {
    check_package_name(name)
  }
  challenge_nested_project(path_dir(path), name)
  challenge_home_directory(path)

  create_directory(path)
  local_project(path, force = TRUE)

  use_directory("R")
  proj_desc_create(name, fields, roxygen)
  use_namespace(roxygen = roxygen)

  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(proj_get())) {
      # working directory/active project already set; clear the scheduled
      # restoration of the original project
      withr::deferred_clear()
    }
  }

  invisible(proj_get())
}

#' @export
#' @rdname create_package
create_project <- function(path,
                           rstudio = rstudioapi::isAvailable(),
                           open = rlang::is_interactive()) {
  path <- user_path_prep(path)
  name <- path_file(path_abs(path))
  challenge_nested_project(path_dir(path), name)
  challenge_home_directory(path)

  create_directory(path)
  local_project(path, force = TRUE)

  use_directory("R")

  if (rstudio) {
    use_rstudio()
  } else {
    ui_bullets(c(
      "v" = "Writing a sentinel file {.path {pth('.here')}}.",
      "_" = "Build robust paths within your project via {.fun here::here}.",
      "i" = "Learn more at {.url https://here.r-lib.org}."
    ))
    file_create(proj_path(".here"))
  }

  if (open) {
    if (proj_activate(proj_get())) {
      # working directory/active project already set; clear the scheduled
      # restoration of the original project
      withr::deferred_clear()
    }
  }

  invisible(proj_get())
}



#' @rdname create_package
#' @export
create_quarto_project <- function(path,
                                  type = "default",
                                  rstudio = rstudioapi::isAvailable(),
                                  open = rlang::is_interactive()) {
  browser()
  check_installed("quarto")

  path <- user_path_prep(path)
  parent_dir <- path_dir(path)
  check_path_is_directory(parent_dir)

  # why do I call path_abs() here?
  name <- path_file(path_abs(path))
  challenge_nested_project(parent_dir, name)
  challenge_home_directory(path)

  create_directory(path)
  local_project(path, force = TRUE)

  res <- quarto::quarto_create_project(
    name = name,
    dir = parent_dir,
    type = type,
    no_prompt = TRUE,
    quiet = getOption("usethis.quiet", default = FALSE)
  )

  if (open) {
    if (proj_activate(proj_get())) {
      # working directory/active project already set; clear the scheduled
      # restoration of the original project
      withr::deferred_clear()
    }
  }

  invisible(proj_get())
}

#' Create a project from a GitHub repo
#'
#' @description
#' Creates a new local project and Git repository from a repo on GitHub, by
#' either cloning or
#' [fork-and-cloning](https://docs.github.com/en/get-started/quickstart/fork-a-repo).
#' In the fork-and-clone case, `create_from_github()` also does additional
#' remote and branch setup, leaving you in the perfect position to make a pull
#' request with [pr_init()], one of several [functions for working with pull
#' requests][pull-requests].
#'
#' `create_from_github()` works best when your GitHub credentials are
#' discoverable. See below for more about authentication.
#'
#' @template double-auth
#'
#' @seealso
#' * [use_github()] to go the opposite direction, i.e. create a GitHub repo
#'   from your local repo
#' * [git_protocol()] for background on `protocol` (HTTPS vs SSH)
#' * [use_course()] to download a snapshot of all files in a GitHub repo,
#'   without the need for any local or remote Git operations
#'
#' @inheritParams create_package
#' @param repo_spec A string identifying the GitHub repo in one of these forms:
#'   * Plain `OWNER/REPO` spec
#'   * Browser URL, such as `"https://github.com/OWNER/REPO"`
#'   * HTTPS Git URL, such as `"https://github.com/OWNER/REPO.git"`
#'   * SSH Git URL, such as `"git@github.com:OWNER/REPO.git"`
#' @param destdir Destination for the new folder, which will be named according
#'   to the `REPO` extracted from `repo_spec`. Defaults to the location stored
#'   in the global option `usethis.destdir`, if defined, or to the user's
#'   Desktop or similarly conspicuous place otherwise.
#' @param fork If `FALSE`, we clone `repo_spec`. If `TRUE`, we fork
#'   `repo_spec`, clone that fork, and do additional setup favorable for
#'   future pull requests:
#'   * The source repo, `repo_spec`, is configured as the `upstream` remote,
#'   using the indicated `protocol`.
#'   * The local `DEFAULT` branch is set to track `upstream/DEFAULT`, where
#'   `DEFAULT` is typically `main` or `master`. It is also immediately pulled,
#'   to cover the case of a pre-existing, out-of-date fork.
#'
#'   If `fork = NA` (the default), we check your permissions on `repo_spec`. If
#'   you can push, we set `fork = FALSE`, If you cannot, we set `fork = TRUE`.
#' @param host GitHub host to target, passed to the `.api_url` argument of
#'   [gh::gh()]. If `repo_spec` is a URL, `host` is extracted from that.
#'
#'   If unspecified, gh defaults to "https://api.github.com", although gh's
#'   default can be customised by setting the GITHUB_API_URL environment
#'   variable.
#'
#'   For a hypothetical GitHub Enterprise instance, either
#'   "https://github.acme.com/api/v3" or "https://github.acme.com" is
#'   acceptable.
#' @param rstudio Initiate an [RStudio
#'   Project](https://r-pkgs.org/workflow101.html#sec-workflow101-rstudio-projects)?
#'   Defaults to `TRUE` if in an RStudio session and project has no
#'   pre-existing `.Rproj` file. Defaults to `FALSE` otherwise (but note that
#'   the cloned repo may already be an RStudio Project, i.e. may already have a
#'   `.Rproj` file).
#' @inheritParams use_github
#'
#' @export
#' @examples
#' \dontrun{
#' create_from_github("r-lib/usethis")
#'
#' # repo_spec can be a URL
#' create_from_github("https://github.com/r-lib/usethis")
#'
#' # a URL repo_spec also specifies the host (e.g. GitHub Enterprise instance)
#' create_from_github("https://github.acme.com/OWNER/REPO")
#' }
create_from_github <- function(repo_spec,
                               destdir = NULL,
                               fork = NA,
                               rstudio = NULL,
                               open = rlang::is_interactive(),
                               protocol = git_protocol(),
                               host = NULL) {
  check_protocol(protocol)

  parsed_repo_spec <- parse_repo_url(repo_spec)
  if (!is.null(parsed_repo_spec$host)) {
    repo_spec <- parsed_repo_spec$repo_spec
    host <- parsed_repo_spec$host
  }

  whoami <- suppressMessages(gh::gh_whoami(.api_url = host))
  no_auth <- is.null(whoami)
  user <- if (no_auth) NULL else whoami$login
  hint <- code_hint_with_host("gh_token_help", host)

  if (no_auth && is.na(fork)) {
    ui_abort(c(
      "x" = "Unable to discover a GitHub personal access token.",
      "x" = "Therefore, can't determine your permissions on {.val {repo_spec}}.",
      "x" = "Therefore, can't decide if {.arg fork} should be {.code TRUE} or {.code FALSE}.",
      "",
      "i" = "You have two choices:",
      "_" = "Make your token available (if in doubt, DO THIS):",
      " " = "Call {.code {hint}} for instructions that should help.",
      "_" = "Call {.fun create_from_github} again, but with {.code fork = FALSE}.",
      " " = "Only do this if you are absolutely sure you don't want to fork.",
      " " = "Note you will NOT be in a position to make a pull request."
    ))
  }

  if (no_auth && isTRUE(fork)) {
    ui_abort(c(
      "x" = "Unable to discover a GitHub personal access token.",
      "i" = "A token is required in order to fork {.val {repo_spec}}.",
      "_" = "Call {.code {hint}} for help configuring a token."
    ))
  }
  # one of these is true:
  # - gh is discovering a token for `host`
  # - gh is NOT discovering a token, but `fork = FALSE`, so that's OK

  source_owner <- spec_owner(repo_spec)
  repo_name <- spec_repo(repo_spec)
  gh <- gh_tr(list(repo_owner = source_owner, repo_name = repo_name, api_url = host))

  repo_info <- gh("GET /repos/{owner}/{repo}")
  # 2023-01-28 We're seeing the GitHub bug again around default branch in a
  # fresh fork. If I create a fork, the POST payload *sometimes* mis-reports the
  # default branch. I.e. it reports `main`, even though the actual default
  # branch is `master`. Therefore we're reverting to consulting the source repo
  # for this info
  default_branch <- repo_info$default_branch

  if (is.na(fork)) {
    fork <- !isTRUE(repo_info$permissions$push)
    fork_status <- glue("fork = {fork}")
    ui_bullets(c("v" = "Setting {.code {fork_status}}."))
  }
  # fork is either TRUE or FALSE

  if (fork && identical(user, repo_info$owner$login)) {
    ui_abort("
      Can't fork, because the authenticated user {.val {user}} already owns the
      source repo {.val {repo_info$full_name}}.")
  }

  destdir <- user_path_prep(destdir %||% conspicuous_place())
  check_path_is_directory(destdir)
  challenge_nested_project(destdir, repo_name)
  repo_path <- path(destdir, repo_name)
  create_directory(repo_path)
  check_directory_is_empty(repo_path)

  if (fork) {
    ## https://developer.github.com/v3/repos/forks/#create-a-fork
    ui_bullets(c("v" = "Forking {.val {repo_info$full_name}}."))
    upstream_url <- switch(
      protocol,
      https = repo_info$clone_url,
      ssh = repo_info$ssh_url
    )
    repo_info <- gh("POST /repos/{owner}/{repo}/forks")
    ui_bullets(c("i" = "Waiting for the fork to finalize before cloning..."))
    Sys.sleep(3)
  }

  origin_url <- switch(
    protocol,
    https = repo_info$clone_url,
    ssh = repo_info$ssh_url
  )

  ui_bullets(c(
    "v" = "Cloning repo from {.val {origin_url}} into {.path {repo_path}}."
  ))
  gert::git_clone(origin_url, repo_path, verbose = FALSE)

  proj_path <- find_rstudio_root(repo_path)
  local_project(proj_path, force = TRUE) # schedule restoration of project

  # 2023-01-28 again, it would be more natural to trust the default branch of
  # the fork, but that cannot always be trusted. For now, we're still using
  # the default branch learned from the source repo.
  ui_bullets(c("i" = "Default branch is {.val {default_branch}}."))

  if (fork) {
    ui_bullets(c(
      "v" = "Adding {.val upstream} remote: {.val {upstream_url}}"
    ))
    use_git_remote("upstream", upstream_url)
    pr_merge_main()
    upstream_remref <- glue("upstream/{default_branch}")
    ui_bullets(c(
      "v" = "Setting remote tracking branch for local {.val {default_branch}}
             branch to {.val {upstream_remref}}."
    ))
    gert::git_branch_set_upstream(upstream_remref, repo = git_repo())
    config_key <- glue("remote.upstream.created-by")
    gert::git_config_set(config_key, "usethis::create_from_github", repo = git_repo())
  }

  rstudio <- rstudio %||% rstudio_available()
  rstudio <- rstudio && !is_rstudio_project()
  if (rstudio) {
    use_rstudio(reformat = FALSE)
  }

  if (open) {
    if (proj_activate(proj_get())) {
      # Working directory/active project changed; so don't undo on exit
      withr::deferred_clear()
    }
  }

  invisible(proj_get())
}

# If there's a single directory containing an .Rproj file, use it.
# Otherwise work in the repo root
find_rstudio_root <- function(path) {
  rproj <- rproj_paths(path, recurse = TRUE)
  if (length(rproj) == 1) {
    path_dir(rproj)
  } else {
    path
  }
}

challenge_nested_project <- function(path, name) {
  if (!possibly_in_proj(path)) {
    return(invisible())
  }

  # creates an undocumented backdoor we can exploit when the interactive
  # approval is impractical, e.g. in tests
  if (isTRUE(getOption("usethis.allow_nested_project", FALSE))) {
    return(invisible())
  }

  ui_bullets(c(
    "!" = "New project {.val {name}} is nested inside an existing project
           {.path {pth(path)}}, which is rarely a good idea.",
    "i" = "If this is unexpected, the {.pkg here} package has a function,
           {.fun here::dr_here} that reveals why {.path {pth(path)}} is regarded
           as a project."
  ))
  if (ui_nah("Do you want to create anyway?")) {
    ui_abort("Cancelling project creation.")
  }
  invisible()
}

challenge_home_directory <- function(path) {
  homes <- unique(c(path_home(), path_home_r()))
  if (!path %in% homes) {
    return(invisible())
  }

  qualification <- if (is_windows()) {
    glue("a special directory, i.e. some applications regard it as ")
  } else {
    ""
  }
  ui_bullets(c(
    "!" = "{.path {pth(path)}} is {qualification}your home directory.",
    "i" = "It is generally a bad idea to create a new project here.",
    "i" = "You should probably create your new project in a subdirectory."
  ))
  if (ui_nah("Do you want to create anyway?")) {
    ui_abort("Good move! Cancelling project creation.")
  }
  invisible()
}
