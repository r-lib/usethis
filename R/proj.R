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

  message <- glue("Project {value(project_name())} is not an R package.")
  if (!is.null(whos_asking)) {
    message <- glue(
      "{code(whos_asking)} is designed to work with packages. {message}"
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
#' session. Use `proj_get()` to see the active project and `proj_set()` to
#' set it manually.
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
  path <- proj_path_prep(path)

  if (force) {
    proj$cur <- path
    return(invisible(old))
  }

  new_proj <- proj_path_prep(proj_find(path))
  if (is.null(new_proj)) {
    stop(glue(
      "Path {value(path)} does not appear to be inside a project or package."
    ), call. = FALSE)
  }
  proj$cur <- new_proj
  invisible(old)
}

proj_path <- function(..., ext = "") path(proj_get(), ..., ext = ext)

proj_rel_path <- function(path) {
  if (is_in_proj(path)) {
    path_rel(path, start = proj_get())
  } else {
    path
  }
}

## usethis policy re: preparation of the path to active project
proj_path_prep <- function(path) {
  if (is.null(path)) return(path)
  path_real(path)
}

## usethis policy re: preparation of user-provided path to a resource on user's
## file system
user_path_prep <- function(path) {
  ## usethis uses fs's notion of home directory
  ## this ensures we are consistent about that
  path_expand(path)
}

is_in_proj <- function(path) {
  ## realize path, if possible; use "as is", otherwise
  path <- tryCatch(path_real(path), error = function(e) NULL) %||% path
  identical(
    proj_get(),
    path_common(c(proj_get(), path))
  )
}
