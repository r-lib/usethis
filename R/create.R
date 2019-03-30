#' Create a package or project
#'
#' @description
#' These functions create an R project:
#'   * `create_package()` creates an R package
#'   * `create_project()` creates a non-package project, i.e. a data analysis
#'   project
#'
#' Both functions can be called on an existing project; you will be asked
#' before any existing files are changed.
#'
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @inheritParams use_description
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
#' @export
create_package <- function(path,
                           fields = NULL,
                           rstudio = rstudioapi::isAvailable(),
                           open = interactive()) {
  path <- user_path_prep(path)
  check_path_is_directory(path_dir(path))

  name <- path_file(path)
  check_package_name(name)
  check_not_nested(path_dir(path), name)

  create_directory(path)
  old_project <- proj_set(path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  use_directory("R")
  use_description(fields)
  use_namespace()

  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(path)) {
      # Working directory/active project changed; so don't undo on exit
      on.exit()
    }
  }

  invisible(proj_get())
}

#' @export
#' @rdname create_package
create_project <- function(path,
                           rstudio = rstudioapi::isAvailable(),
                           open = interactive()) {
  path <- user_path_prep(path)
  name <- path_file(path)
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
    if (proj_activate(path)) {
      # Working directory/active project changed; so don't undo on exit
      on.exit()
    }
  }

  invisible(proj_get())
}

#' Create a project from a GitHub repo
#'
#' Creates a new local Git repository from a repository on GitHub. It is highly
#' recommended that you pre-configure or pass a GitHub personal access token
#' (PAT), which is facilitated by [browse_github_token()]. In particular, a PAT
#' is required in order for `create_from_github()` to do ["fork and
#' clone"](https://help.github.com/articles/fork-a-repo/). It is also required
#' by [use_github()], which connects existing local projects to GitHub.
#'
#' @seealso [use_github()] for GitHub setup advice. [git_protocol()] and
#'   [git2r_credentials()] for background on `protocol` and `credentials`.
#'   [use_course()] for one-time download of all files in a Git repo, without
#'   any local or remote Git operations.
#'
#' @inheritParams create_package
#' @param repo_spec GitHub repo specification in this form: `owner/repo`. The
#'   `repo` part will be the name of the new local repo.
#' @inheritParams use_course
#' @param fork If `TRUE`, we create and clone a fork. If `FALSE`, we clone
#'   `repo_spec` itself. Will be set to `FALSE` if no `auth_token` (a.k.a. PAT)
#'   is provided or preconfigured. Otherwise, defaults to `FALSE` if you can
#'   push to `repo_spec` and `TRUE` if you cannot. If a fork is created, the
#'   original target repo is added to the local repo as the `upstream` remote,
#'   using your preferred `protocol`, to make it easier to pull upstream changes
#'   in the future.
#' @param rstudio Initiate an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)?
#'    Defaults to `TRUE` if in an RStudio session and project has no
#'   pre-existing `.Rproj` file. Defaults to `FALSE` otherwise.
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
                               open = interactive(),
                               protocol = git_protocol(),
                               credentials = NULL,
                               auth_token = github_token(),
                               host = NULL) {
  destdir <- user_path_prep(destdir %||% conspicuous_place())
  check_path_is_directory(destdir)

  owner <- spec_owner(repo_spec)
  repo <- spec_repo(repo_spec)
  check_not_nested(destdir, repo)

  repo_path <- path(destdir, repo)
  create_directory(repo_path)
  check_directory_is_empty(repo_path)

  auth_token <- check_github_token(auth_token, allow_empty = TRUE)

  gh <- function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      .token = auth_token,
      .api_url = host
    )
  }

  repo_info <- gh("GET /repos/:owner/:repo", owner = owner, repo = repo)

  fork <- rationalize_fork(fork, repo_info, auth_token)
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
      owner = owner, repo = repo
    )
  }

  origin_url <- switch(
    protocol,
    https = repo_info$clone_url,
    ssh = repo_info$ssh_url
  )

  ui_done("Cloning repo from {ui_value(origin_url)} into {ui_value(repo_path)}")
  credentials <- credentials %||% git2r_credentials(protocol, auth_token)
  git2r::clone(
    origin_url,
    repo_path,
    credentials = credentials,
    progress = FALSE
  )
  old_project <- proj_set(repo_path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  if (fork) {
    r <- git2r::repository(proj_get())
    ui_done("Adding {ui_value('upstream')} remote: {ui_value(upstream_url)}")
    git2r::remote_add(r, "upstream", upstream_url)
  }

  rstudio <- rstudio %||% rstudioapi::isAvailable()
  rstudio <- rstudio && !is_rstudio_project(proj_get())
  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(repo_path)) {
      # Working directory/active project changed; so don't undo on exit
      on.exit()
    }
  }

  invisible(proj_get())
}

check_not_nested <- function(path, name) {
  if (!possibly_in_proj(path)) {
    return(invisible())
  }

  ## special case: allow nested project if
  ## 1) is_testing()
  ## 2) proposed project name matches magic string we build into test projects
  ## https://github.com/r-lib/usethis/pull/241
  if (is_testing() && grepl("aaa", name)) {
    return()
  }

  ui_line(
    "New project {ui_value(name)} is nested inside an existing project \\
    {ui_path(path)}, which is rarely a good idea."
  )
  if (ui_nope("Do you want to create anyway?")) {
    ui_stop("Aborting project creation.")
  }
  invisible()
}

rationalize_fork <- function(fork, repo_info, auth_token) {
  have_token <- have_github_token(auth_token)
  can_push <- isTRUE(repo_info$permissions)
  repo_owner <- repo_info$owner$login
  user <- if (have_token) github_user(auth_token)[["login"]]

  if (is.na(fork)) {
    fork <- have_token && !can_push
  }

  if (fork && !have_token) {
    ## throw the usual error for bad/missing token
    check_github_token(auth_token)
  }

  if (fork && identical(user, repo_owner)) {
    ui_stop(
      "Repo {ui_value(repo_info$full_name)} is owned by user \\
      {ui_value(user)}. Can't fork."
    )
  }

  fork
}
