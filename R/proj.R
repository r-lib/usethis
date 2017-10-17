proj <- new.env(parent = emptyenv())

proj_find <- function(path = ".") {
  criteria <- rprojroot::has_file(".here") |
    rprojroot::is_rstudio_project |
    rprojroot::is_r_package |
    rprojroot::is_remake_project |
    rprojroot::is_projectile_project |
    rprojroot::is_vcs_root

  rprojroot::find_root(criteria, path = path)
}


#' Get and set currently active project
#'
#' When attached, usethis uses rprojroot to find the project root of the
#' current working directory. It establishes the project root by looking for
#' for a `.here` file, an RStudio project, a package `DESCRIPTION`, a
#' `remake.yml`, `.projectile` file, or `.git`/`.svn` directories. It then
#' stores the project directory for use for the remainder of the session.
#' If needed, you can manually override by running `proj_set()`.
#'
#' @param path Path to set.
#' @param force If `TRUE`, uses this path without checking if any parent
#'   directories are existing projects.
#' @keywords internal
proj_get <- function() {
  proj$cur
}

#' @export
#' @rdname proj_get
proj_set <- function(path = ".", force = FALSE) {
  old <- proj_get()

  if (force) {
    proj$cur <- proj_find(path)
  } else {
    proj$cur <- path
  }

  invisible(old)
}

scoped_temporary_package <- function(dir = tempfile(), env = parent.frame()) {
  old <- proj_get()
  withr::defer(proj_set(old), envir = env)

  utils::capture.output(create_package(dir, rstudio = FALSE, open = FALSE))
  invisible(dir)
}

.onAttach <- function(...) {
  proj_set(".")
}
