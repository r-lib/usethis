#' Create a package or project
#'
#' @description
#' These functions create an R project:
#'   * `create_package()` creates an R package
#'   * `create_project()` creates a non-package project, i.e. a data analysis
#'   project
#'
#' Both functions can add project infrastructure to an existing directory of
#' files or can create a completely new project. Both functions change the
#' active project, so that subsequent `use_*()` calls affect the project
#' that you've just created. See [proj_set()] to manually reset it.
#'
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @inheritParams use_description
#' @param rstudio If `TRUE`, calls [use_rstudio()] to make the new package or
#'   project into an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).
#'    If `FALSE` and a non-package project, a sentinel `.here` file is placed so
#'   that the directory can be recognized as a project by the
#'   [here](https://krlmlr.github.io/here/) or
#'   [rprojroot](https://krlmlr.github.io/rprojroot/) packages.
#' @param open If `TRUE` and in RStudio, the new project is opened in a new
#'   instance, if possible, or is switched to, otherwise. If `TRUE` and not
#'   in RStudio, working directory is set to the new project.
#' @export
create_package <- function(path,
                           fields = getOption("devtools.desc"),
                           rstudio = rstudioapi::isAvailable(),
                           open = interactive()) {
  path <- normalizePath(path, mustWork = FALSE)

  name <- basename(path)
  check_package_name(name)
  check_not_nested(dirname(path), name)

  create_directory(dirname(path), name)
  cat_line(crayon::bold("Changing active project to", crayon::red(name)))
  ## the initial normalizePath() may not have returned an absolute path,
  ## if the path did not yet exist
  path <- normalizePath(path, mustWork = TRUE)
  proj_set(path, force = TRUE)

  use_directory("R")
  use_directory("man")
  use_description(fields = fields)
  use_namespace()

  if (rstudio) {
    use_rstudio()
  }
  if (open) {
    open_project(path, name, rstudio = rstudio)
  }

  invisible(TRUE)
}

#' @export
#' @rdname create_package
create_project <- function(path,
                           rstudio = rstudioapi::isAvailable(),
                           open = interactive()) {
  path <- normalizePath(path, mustWork = FALSE)

  name <- basename(path)
  check_not_nested(dirname(path), name)

  create_directory(dirname(path), name)
  cat_line(crayon::bold("Changing active project to", crayon::red(name)))
  ## the initial normalizePath() may not have returned an absolute path,
  ## if the path did not yet exist
  path <- normalizePath(path, mustWork = TRUE)
  proj_set(path, force = TRUE)

  use_directory("R")

  if (rstudio) {
    use_rstudio()
  } else {
    done("Writing a sentinel file ", value(".here"))
    todo(
      "Build robust paths within your project via ",
      code("here::here()")
    )
    todo("Learn more at https://krlmlr.github.io/here/")
    writeLines(character(), file.path(path, ".here"))
  }
  if (open) {
    open_project(path, name, rstudio = rstudio)
  }

  invisible(TRUE)
}

#' Create a project from a GitHub repo
#'
#' Creates a new local Git repository from a repository on GitHub. It is highly
#' recommended that you pre-configure or pass a GitHub personal access token
#' (PAT), which is facilitated by [browse_github_pat()]. In particular, a PAT is
#' required in order for `create_from_github()` to do ["fork and
#' clone"](https://help.github.com/articles/fork-a-repo/). It is also required
#' by [use_github()], which connects existing local projects to GitHub.
#'
#' @seealso [use_course()] for one-time download of all files in a Git repo,
#'   without any local or remote Git operations.
#'
#' @inheritParams create_package
#' @param repo GitHub repo specification in this form: `owner/reponame`. The
#'   second part will be the name of the new local repo.
#' @inheritParams use_course
#' @param fork If `TRUE`, we create and clone a fork. If `FALSE`, we clone
#'   `repo` itself. Will be set to `FALSE` if no `auth_token` (a.k.a. PAT) is
#'   provided or preconfigured. Otherwise, if unspecified, defaults to `FALSE`
#'   if you can push to `repo` and `TRUE` if you cannot. If a fork is created,
#'   the original target repo is added to the local repo as the `upstream`
#'   remote, using your preferred `protocol`, to make it easier to pull upstream
#'   changes in the future.
#' @param rstudio Initiate an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)?
#'    Defaults to `TRUE` if in an RStudio session and project has no
#'   pre-existing `.Rproj` file. Defaults to `FALSE` otherwise.
#' @inheritParams use_github
#' @export
#' @examples
#' \dontrun{
#' create_from_github("r-lib/usethis")
#' }
create_from_github <- function(repo,
                               destdir = NULL,
                               fork = NA,
                               rstudio = NULL,
                               open = interactive(),
                               protocol = c("ssh", "https"),
                               credentials = NULL,
                               auth_token = NULL,
                               host = NULL) {
  destdir <- destdir %||% conspicuous_place()
  check_is_dir(destdir)
  check_not_nested(destdir, repo)
  protocol <- match.arg(protocol)

  repo <- strsplit(repo, "/")[[1]]
  if (length(repo) != 2) {
    stop(
      code("repo"), " must be of form ",
      value("owner/reponame"), call. = FALSE
    )
  }
  owner <- repo[[1]]
  repo <- repo[[2]]

  repo_path <- create_directory(destdir, repo)
  if (dir.exists(repo_path)) {
    check_is_empty(repo_path)
  }

  pat <- auth_token %||% gh_token()
  pat_available <- pat != ""
  user <- if (pat_available) gh::gh_whoami(pat)[["login"]] else NULL

  gh <- function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      .token = auth_token,
      .api_url = host
    )
  }

  repo_info <- gh("GET /repos/:owner/:repo", owner = owner, repo = repo)

  fork <- rationalize_fork(fork, repo_info, pat_available, user)
  if (fork) {
    ## https://developer.github.com/v3/repos/forks/#create-a-fork
    done("Forking ", value(repo_info$full_name))
    upstream_url <- switch(
      protocol,
      https = repo_info$clone_url,
      ssh = repo_info$ssh_url
    )
    repo_info <- gh(
      "POST /repos/:owner/:repo/forks", owner = owner, repo = repo
    )
  }

  origin_url <- switch(
    protocol,
    https = repo_info$clone_url,
    ssh = repo_info$ssh_url
  )

  done("Cloning repo from ", value(origin_url), " into ", value(repo_path))
  git2r::clone(
    origin_url,
    normalizePath(repo_path, mustWork = FALSE),
    credentials = credentials,
    progress = FALSE
  )
  proj_set(repo_path)

  if (fork) {
    r <- git2r::repository(proj_get())
    done("Adding ", value("upstream"), " remote: ", value(upstream_url))
    git2r::remote_add(r, "upstream", upstream_url)
  }

  rstudio <- rstudio %||% rstudioapi::isAvailable()
  rstudio <- rstudio && !is_rstudio_project(repo_path)
  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    open_project(repo_path, repo)
  }
}

open_project <- function(path, name, rstudio = NA) {
  project_path <- file.path(normalizePath(path), paste0(name, ".Rproj"))
  if (is.na(rstudio)) {
    rstudio <- file.exists(project_path)
  }

  if (rstudio && rstudioapi::hasFun("openProject")) {
    done("Opening project in RStudio")
    rstudioapi::openProject(project_path, newSession = TRUE)
  } else {
    setwd(path)
    done("Changing working directory to ", value(path))
  }
  invisible(TRUE)
}

check_not_nested <- function(path, name) {
  proj_root <- proj_find(path)

  if (is.null(proj_root)) {
    return(invisible())
  }

  ## special case: allow nested project if
  ## 1) is_testing()
  ## 2) proposed project name matches magic string we build into test projects
  ## https://github.com/r-lib/usethis/pull/241
  if (is_testing() && grepl("aaa", name)) {
    return()
  }

  message <- paste0(
    "New project ", value(name), " is nested inside an existing project ",
    value(proj_root), "."
  )
  if (!interactive()) {
    stop(message, call. = FALSE)
  }

  if (nope(message, " This is rarely a good idea. Do you wish to create anyway?")) {
    stop("Aborting project creation", call. = FALSE)
  }
  invisible()
}

rationalize_fork <- function(fork, repo_info, pat_available, user = NULL) {

  perms <- repo_info$permissions
  owner <- repo_info$owner$login

  if (is.na(fork)) {
    fork <- pat_available && !isTRUE(perms$push)
  }

  if (fork && !pat_available) {
    stop(
      "No GitHub Personal Access Token available. Can't fork.", call. = FALSE
    )
  }

  if (fork && identical(user, owner)) {
    stop(
      "Repo ", value(repo_info$full_name), " is owned by user ",
      value(user), ". Can't fork.", call. = FALSE
    )
  }

  fork
}
