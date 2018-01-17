#' Create a new package or project
#'
#' Both functions change the active project so that subsequent `use_*()` calls
#' will affect the project that you've just created. See [proj_set()] to
#' manually reset it.
#'
#' @inheritParams use_description
#' @param path A path. If it exists, it will be used. If it does not exist, it
#'   will be created (providing that the parent path exists).
#' @param rstudio If `TRUE`, call [use_rstudio()] to make new package or project
#'   into an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).
#' @param open If `TRUE` and in RStudio, new project will be opened in a new
#'   instance, if possible, or will be switched to, otherwise. If `TRUE` and not
#'   in RStudio, working directory will be set to the new project.
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

#' Create a repo and project from GitHub
#'
#' Creates a new local Git repository from a repository on GitHub. If you have
#' pre-configured a GitHub personal access token (PAT) as described in
#' [gh::gh_whoami()], you will get more sensible default behavior for the `fork`
#' argument. You cannot create a fork without a PAT. Currently only works for
#' public repositories. A future version of this function will likely have an
#' interface closer to [use_github()], i.e. more ability to accept credentials
#' and more control over the Git configuration of the affected remote or local
#' repositories.
#'
#' @seealso [use_course()] for one-time download of all files in a Git repo,
#'   without any local or remote Git operations.
#'
#' @inheritParams create_package
#' @param repo GitHub repo specification in this form: `owner/repo`. The second
#'   part, i.e. the GitHub repo name, will be the name of the new local repo.
#' @inheritParams use_course
#' @param fork Create and clone a fork? Or clone `repo` itself? Defaults to
#'   `TRUE` if you can't push to `repo`, `FALSE` if you can.
#' @param rstudio Initiate an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)?
#'    Defaults to `TRUE` if in an RStudio session and project has no
#'   pre-existing `.Rproj` file. Defaults to `FALSE` otherwise.
#' @export
#' @examples
#' \dontrun{
#' create_from_github("r-lib/usethis")
#' }
create_from_github <- function(repo,
                               destdir = NULL,
                               fork = NA,
                               rstudio = NULL,
                               open = interactive()) {
  destdir <- destdir %||% conspicuous_place()
  check_is_dir(destdir)

  repo <- strsplit(repo, "/")[[1]]
  if (length(repo) != 2) {
    stop(
      code("repo"), " must be of form ",
      value("user/reponame"), call. = FALSE
    )
  }
  owner <- repo[[1]]
  repo <- repo[[2]]
  repo_info <- gh::gh("GET /repos/:owner/:repo", owner = owner, repo = repo)

  check_not_nested(destdir, repo)

  if (is.na(fork)) {
    perms <- repo_info$permissions
    if (is.null(perms)) {
      # if permissions are absent, there's no PAT and we can't fork
      fork <- FALSE
    } else {
      # fork only if can't push to the repo
      fork <- !isTRUE(perms$push)
    }
  }
  ## TODO(jennybc): should we also be checking if fork = TRUE but user owns the
  ## repo?

  if (fork) {
    done("Forking repo")
    fork_info <- gh::gh(
      "POST /repos/:owner/:repo/forks",
      owner = owner, repo = repo
    )
    owner <- fork_info$owner$login
    git_url <- fork_info$git_url
  } else {
    git_url <- repo_info$git_url
  }

  repo_path <- create_directory(destdir, repo)
  done("Cloning repo from ", value(git_url), " into ", value(repo_path))
  git2r::clone(git_url, normalizePath(repo_path), progress = FALSE)
  proj_set(repo_path)

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
}
