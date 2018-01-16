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

#' Create a project from a github repository
#'
#' @inheritParams create_package
#' @param repo Full name of repository: `owner/repo`
#' @param fork Create a fork before cloning? Defaults to `TRUE` if you can't
#'   push to `repo`, `FALSE` if you can.
#' @export
create_from_github <- function(repo, path, fork = NA, open = TRUE) {
  repo <- strsplit(repo, "/")[[1]]
  if (length(repo) != 2) {
    stop("`repo` must be of form user/reponame", call. = FALSE)
  }
  owner <- repo[[1]]
  repo <- repo[[2]]
  repo_info <- gh::gh("GET /repos/:owner/:repo", owner = owner, repo = repo)

  check_not_nested(dirname(path), repo)

  # By default, fork only if you can't push to the repo
  if (is.na(fork)) {
    fork <- !repo_info$permissions$push
  }

  if (fork) {
    done("Forking repo")
    fork_info <- gh::gh("POST /repos/:owner/:repo/forks", owner = owner, repo = repo)
    owner <- fork_info$owner$login
    git_url <- fork_info$git_url
  } else {
    git_url <- repo_info$git_url
  }

  done("Cloning repo")
  repo_path <- create_directory(path, repo)
  git2r::clone(git_url, normalizePath(repo_path), progress = FALSE)
  proj_set(repo_path)

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
