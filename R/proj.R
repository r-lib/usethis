proj <- new.env(parent = emptyenv())

proj_crit <- function() {
  rprojroot::has_file(".here") |
    rprojroot::is_rstudio_project |
    rprojroot::is_r_package |
    rprojroot::is_git_root |
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

#' Get and set the active project
#'
#' @description
#' Most `use_*()` functions act on the **active project**. If it is unset,
#' usethis uses [rprojroot](https://krlmlr.github.io/rprojroot/) to find the
#' project root of the current working directory. It establishes the project
#' root by looking for a `.here` file, an RStudio Project, a package
#' `DESCRIPTION`, Git infrastructure, a `remake.yml` file, or a `.projectile`
#' file. It then stores the active project for use for the remainder of the
#' session. If needed, you can manually override by running `proj_set()`.
#'
#' @description In general, user scripts should not call `usethis::proj_get()`
#'   or `usethis::proj_set()`. They are internal functions that are exported for
#'   occasional interactive use. If you need to detect a project
#'   programmatically in your code, you should probably be using
#'   [rprojroot](https://krlmlr.github.io/rprojroot/) or its simpler companion,
#'   [here](https://krlmlr.github.io/here/), directly.
#'
#' @param path Path to set.
#' @param force If `TRUE`, use this path without checking the usual criteria.
#'   Use sparingly! The main application is to solve a temporary chicken-egg
#'   problem: you need to set the active project in order to add
#'   project-signalling infrastructure, such as initialising a Git repo or
#'   adding a DESCRIPTION file.
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' ## see the active project
#' proj_get()
#'
#' ## manually set the active project
#' proj_set("path/to/target/project")
#' }
proj_get <- function() {
  # Called for first time so try working directory
  if (is.null(proj$cur)) {
    proj_set(".")
  }

  proj$cur
}

#' @export
#' @rdname proj_get
proj_set <- function(path = ".", force = FALSE) {
  old <- proj$cur

  check_is_dir(path)

  if (force) {
    proj$cur <- path
    return(invisible(old))
  }

  new_proj <- proj_find(path)
  if (is.null(new_proj)) {
    stop(
      "Path ", value(path),
      " does not appear to be inside a project or package.",
      call. = FALSE
    )
  }
  proj$cur <- new_proj
  invisible(old)
}

proj_path <- function(...) file.path(proj_get(), ...)
