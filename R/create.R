#' Create a package or project
#'
#' @description
#' These functions create an R project:
#'   * `create_package()` creates an R package
#'   * `create_project()` creates a non-package project, i.e. a data analysis
#'   project
#'
#' Both functions can be called on an existing project; you will be asked before
#' any existing files are changed.
#'
#' @inheritParams use_description
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param roxygen Do you plan to use roxygen2 to document your package?
#' @param rstudio If `TRUE`, calls [use_rstudio()] to make the new package or
#'   project into an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).
#'    If `FALSE` and a non-package project, a sentinel `.here` file is placed so
#'   that the directory can be recognized as a project by the
#'   [here](https://here.r-lib.org) or
#'   [rprojroot](https://rprojroot.r-lib.org) packages.
#' @param open If `TRUE`, [activates][proj_activate()] the new project:
#'
#'   * If RStudio desktop, the package is opened in a new session.
#'   * If on RStudio server, the current RStudio project is activated.
#'   * Otherwise, the working directory and active project is changed.
#'
#' @return Path to the newly created project or package, invisibly.
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
  check_not_nested(path_dir(path), name)

  create_directory(path)
  old_project <- proj_set(path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  use_directory("R")
  use_description(fields, check_name = FALSE, roxygen = roxygen)
  use_namespace(roxygen = roxygen)

  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(proj_get())) {
      # working directory/active project already set; clear the on.exit()'s
      on.exit()
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
  check_not_nested(path_dir(path), name)

  create_directory(path)
  old_project <- proj_set(path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  use_directory("R")

  if (rstudio) {
    use_rstudio()
  } else {
    ui_done("Writing a sentinel file {ui_path('.here')}")
    ui_todo("Build robust paths within your project via {ui_code('here::here()')}")
    ui_todo("Learn more at <https://here.r-lib.org>")
    file_create(proj_path(".here"))
  }

  if (open) {
    if (proj_activate(proj_get())) {
      # working directory/active project already set; clear the on.exit()'s
      on.exit()
    }
  }

  invisible(proj_get())
}

#' Create a project from a GitHub repo
#'
#' @description
#' Creates a new local project and Git repository from a repo on GitHub, by
#' either cloning or
#' [fork-and-cloning](https://help.github.com/articles/fork-a-repo/). In the
#' fork-and-clone case, `create_from_github()` also does additional remote and
#' branch setup, leaving you in the perfect position to make a pull request with
#' [pr_init()], one of several [functions that work pull
#' requests][pull-requests].
#'
#' `create_from_github()` works best when we can find a GitHub personal access
#' token in the Git credential store (just like many other usethis functions).
#' * If you do not have a token, [create_github_token()] provides assistance.
#' * Once you have a token, [gitcreds::gitcreds_get()] helps you store it for
#'   future re-discovery and re-use.
#'
#' @seealso
#' * [use_github()] to go the opposite direction, i.e. create a GitHub repo
#'   from your local repo
#' * [git_protocol()] for background on `protocol` (HTTPS vs SSH)
#' * [use_course()] to download a snapshot of all files in a GitHub repo,
#'   without the need for any local or remote Git operations
#'
#' @template double-auth
#'
#' @inheritParams create_package
#' @param repo_spec GitHub repo specification in this form: `owner/repo`. The
#'   `repo` part will be the name of the new local folder, which is also
#'   a project and Git repo.
#' @inheritParams use_course
#' @param fork If `TRUE`, we create and clone a fork. If `FALSE`, we clone
#'   `repo_spec` itself. If `NA` (the default), we check your permissions on the
#'   target repo. If you can push, we clone `repo_spec` (so, `fork = FALSE`).
#'   If you can't push, we do fork-and-clone and other setup:
#'   * The source repo is configured as the `upstream` remote, using the
#'     indicated `protocol`.
#'   * The local `DEFAULT` branch is set to track `upstream/DEFAULT`, where
#'     `DEFAULT` is typically `master` or `main`. It is also immediately
#'     pulled, to cover the case of a pre-existing, out-of-date fork.
#' @param rstudio Initiate an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)?
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
#' }
create_from_github <- function(repo_spec,
                               destdir = NULL,
                               fork = NA,
                               rstudio = NULL,
                               open = rlang::is_interactive(),
                               protocol = git_protocol(),
                               host = "https://github.com",
                               auth_token = deprecated(),
                               credentials = deprecated()) {
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("create_from_github")
  }
  if (lifecycle::is_present(credentials)) {
    deprecate_warn_credentials("create_from_github")
  }

  host_url <- gh:::get_hosturl(host)
  api_url <- gh:::get_apiurl(host)
  auth_token <- gitcreds_token(host_url)

  if (auth_token == "" && is.na(fork)) {
    create_code <- "usethis::create_github_token()"
    set_code <- glue("gitcreds::gitcreds_set(\"{host_url}\")")
    ui_stop("
      Unable to discover a token for {ui_value(host_url)}
      Therefore, can't determine your permissions on {ui_value(repo_spec)}

      You have two choices:
      1. Make your token available (if in doubt, DO THIS):
         - If you don't have a token yet, use {ui_code(create_code)}
         - Store your token with {ui_code(set_code)}
      2. Call {ui_code('create_from_github()')} again, but with \\
      {ui_code('fork = FALSE')}
         - Only do this if you are absolutely sure you don't want to fork
         - Note you will NOT be in a position to make a pull request.")
  }

  if (auth_token == "" && isTRUE(fork)) {
    create_code <- "usethis::create_github_token()"
    set_code <- glue("gitcreds::gitcreds_set(\"{host_url}\")")
    ui_stop("
      Unable to discover a token for {ui_value(host_url)}
      A token is required in order to fork {ui_value(repo_spec)}

      How to make a token available:
        - If you don't have a token yet, use {ui_code(create_code)}
        - Store your token with {ui_code(set_code)}")
  }
  # one of these is true:
  # - we have what appears to be a real auth_token
  # - we do NOT have an auth_token AND `fork = FALSE`

  gh <- function(endpoint, ...) {
    gh::gh(endpoint, ..., .token = auth_token, .api_url = api_url)
  }

  source_owner <- spec_owner(repo_spec)
  repo_name <- spec_repo(repo_spec)

  repo_info <- gh(
    "GET /repos/:owner/:repo",
    owner = source_owner, repo = repo_name
  )

  if (auth_token != "" && is.na(fork)) {
    fork <- !isTRUE(repo_info$permissions$push)
  }
  # fork is either TRUE or FALSE

  if (fork) {
    user <- github_login(auth_token, api_url)
    if (identical(user, repo_info$owner$login)) {
      ui_stop("
        Repo {ui_value(repo_info$full_name)} is owned by user \\
        {ui_value(user)}. Can't fork.")
    }
  }

  destdir <- user_path_prep(destdir %||% conspicuous_place())
  check_path_is_directory(destdir)
  check_not_nested(destdir, repo_name)
  repo_path <- path(destdir, repo_name)
  create_directory(repo_path)
  check_directory_is_empty(repo_path)

  if (fork) {
    ## https://developer.github.com/v3/repos/forks/#create-a-fork
    ui_done("Forking {ui_value(repo_info$full_name)}")
    upstream_url <- switch(
      protocol,
      https = repo_info$clone_url,
      ssh = repo_info$ssh_url
    )
    repo_info <- gh(
      "POST /repos/:owner/:repo/forks",
      owner = source_owner, repo = repo_name
    )
  }

  origin_url <- switch(
    protocol,
    https = repo_info$clone_url,
    ssh = repo_info$ssh_url
  )

  ui_done("Cloning repo from {ui_value(origin_url)} into {ui_value(repo_path)}")
  gert::git_clone(origin_url, repo_path, verbose = FALSE)
  local_project(repo_path, force = TRUE) # schedule restoration of project

  default_branch <- repo_info$default_branch
  ui_info("Default branch is {ui_value(default_branch)}")

  if (fork) {
    ui_done("Adding {ui_value('upstream')} remote: {ui_value(upstream_url)}")
    use_git_remote("upstream", upstream_url)
    pr_merge_main()
    upstream_remref <- glue("upstream/{default_branch}")
    ui_done("
      Setting remote tracking branch for local {ui_value(default_branch)} \\
      branch to {ui_value(upstream_remref)}")
    gert::git_branch_set_upstream(upstream_remref, repo = git_repo())
    config_key <- glue("remote.upstream.created-by")
    gert::git_config_set(config_key, "usethis::create_from_github", repo = git_repo())
  }

  rstudio <- rstudio %||% rstudioapi::isAvailable()
  rstudio <- rstudio && !is_rstudio_project(proj_get())
  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(repo_path)) {
      # Working directory/active project changed; so don't undo on exit
      withr::deferred_clear()
    }
  }

  invisible(proj_get())
}

# creates a backdoor we can exploit in tests
allow_nested_project <- function() FALSE

check_not_nested <- function(path, name) {
  if (!possibly_in_proj(path)) {
    return(invisible())
  }

  # we mock this in a few tests, to allow a nested project
  if (allow_nested_project()) {
    return()
  }

  ui_line(
    "New project {ui_value(name)} is nested inside an existing project \\
    {ui_path(path)}, which is rarely a good idea.
    If this is unexpected, the here package has a function, \\
    {ui_code('here::dr_here()')} that reveals why {ui_path(path)} \\
    is regarded as a project."
  )
  if (ui_nope("Do you want to create anyway?")) {
    ui_stop("Aborting project creation.")
  }
  invisible()
}
