proj <- new.env(parent = emptyenv())

proj_crit <- function() {
  rprojroot::has_file(".here") |
    rprojroot::is_rstudio_project |
    rprojroot::is_r_package |
    rprojroot::is_remake_project |
    rprojroot::is_projectile_project
}

proj_find <- function(path = ".") {
  tryCatch(
    rprojroot::find_root(proj_crit(), path = path),
    error = function(e) NULL
  )
}

is_proj <- function(path = ".") !is.null(proj_find(path))

is_package <- function(base_path = proj_get()) {
  res <- tryCatch(
    rprojroot::find_package_root_file(path = base_path),
    error = function(e) NULL
  )
  !is.null(res)
}

check_is_package <- function(whos_asking = NULL) {
  if (is_package()) {
    return(invisible())
  }

  message <- paste0(
    "Project ", value(project_name()), " is not an R package."
  )
  if (!is.null(whos_asking)) {
    message <- paste0(
      code(whos_asking),
      " is designed to work with packages. ",
      message
    )
  }
  stop(message, call. = FALSE)
}

#' Get and set currently active project
#'
#' When attached, usethis uses rprojroot to find the project root of the
#' current working directory. It establishes the project root by looking for
#' for a `.here` file, an RStudio project, a package `DESCRIPTION`, a
#' `remake.yml`, or a `.projectile` file. It then stores the project directory
#' for use for the remainder of the session. If needed, you can manually
#' override by running `proj_set()`.
#'
#' @param path Path to set.
#' @param force If `TRUE`, uses this path without checking if any parent
#'   directories are existing projects.
#' @keywords internal
#' @export
proj_get <- function() {
  if (!is.null(proj$cur)) {
    return(proj$cur)
  }

  # Try current wd
  proj_set(".")
  if (!is.null(proj$cur)) {
    return(proj$cur)
  }

  stop(
    "Current working directory, ", value(normalizePath(".")), ", ",
    " does not appear to be inside a project or package.",
    call. = FALSE
  )
}

#' @export
#' @rdname proj_get
proj_set <- function(path = ".", force = FALSE) {
  old <- proj$cur

  if (force) {
    proj$cur <- path
  } else {
    proj$cur <- proj_find(path)
  }

  invisible(old)
}

## check vectorizaion
proj_path <- function(...) file.path(proj_get(), ...)

.onAttach <- function(...) {
  proj_set(".")
}
