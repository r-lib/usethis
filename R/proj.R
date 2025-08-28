proj <- new.env(parent = emptyenv())

proj_get_ <- function() proj$cur

proj_set_ <- function(path) {
  old <- proj$cur
  proj$cur <- path
  invisible(old)
}

#' Utility functions for the active project
#'
#' @description
#' Most `use_*()` functions act on the **active project**. If it is
#' unset, usethis uses [rprojroot](https://rprojroot.r-lib.org) to
#' find the project root of the current working directory. It establishes the
#' project root by looking for signs such as:
#' * a `.here` file
#' * an RStudio Project, i.e. a `.Rproj` file
#' * an R package, i.e. a `DESCRIPTION` file
#' * a Git repository
#' * a Positron or VS Code workspace, i.e. a `.vscode/settings.json` file
#' * a Quarto project, i.e. a `_quarto.yml` file
#' * an renv project, i.e. a `renv.lock` file
#'
#' usethis then stores the active project for use for the remainder of the
#' session.
#'
#' In general, end user scripts should not contain direct calls to
#' `usethis::proj_*()` utility functions. They are internal functions that are
#' exported for occasional interactive use or use in packages that extend
#' usethis. End user code should call `here::here()` or other functions from
#' the [here](https://here.r-lib.org) or
#' [rprojroot](https://rprojroot.r-lib.org) packages to programmatically
#' detect a project and build paths within it.
#'
#' If you are puzzled why a path (usually the current working directory) does
#' *not* appear to be inside project, it can be helpful to call
#' `here::dr_here()` to get much more verbose feedback.
#'
#' @name proj_utils
#' @family project functions
#' @examples
#' \dontrun{
#' ## see the active project
#' proj_get()
#'
#' ## manually set the active project
#' proj_set("path/to/target/project")
#'
#' ## build a path within the active project (both produce same result)
#' proj_path("R/foo.R")
#' proj_path("R", "foo", ext = "R")
#'
#' ## build a path within SOME OTHER project
#' with_project("path/to/some/other/project", proj_path("blah.R"))
#'
#' ## convince yourself that with_project() temporarily changes the project
#' with_project("path/to/some/other/project", print(proj_sitrep()))
#' }
NULL

#' @describeIn proj_utils Retrieves the active project and, if necessary,
#'   attempts to set it in the first place.
#' @export
proj_get <- function() {
  # Called for first time so try working directory
  if (!proj_active()) {
    proj_set(".")
  }

  proj_get_()
}

#' @describeIn proj_utils Sets the active project.
#' @param path Path to set. This `path` should exist or be `NULL`.
#' @param force If `TRUE`, use this path without checking the usual criteria for
#'   a project. Use sparingly! The main application is to solve a temporary
#'   chicken-egg problem: you need to set the active project in order to add
#'   project-signalling infrastructure, such as initialising a Git repo or
#'   adding a `DESCRIPTION` file.
#' @export
proj_set <- function(path = ".", force = FALSE) {
  if (!force && dir_exists(path %||% "") && is_in_proj(path)) {
    return(invisible(proj_get_()))
  }

  path <- proj_path_prep(path)
  if (is.null(path) || force) {
    proj_string <- if (is.null(path)) "<no active project>" else path
    ui_bullets(c("v" = "Setting active project to {.val {proj_string}}."))
    return(proj_set_(path))
  }

  check_path_is_directory(path)
  new_project <- proj_find(path)
  if (is.null(new_project)) {
    ui_abort(c(
      "Path {.path {pth(path)}} does not appear to be inside a project or package.",
      "Read more in the help for {.fun usethis::proj_get}."
    ))
  }
  proj_set(path = new_project, force = TRUE)
}

#' @describeIn proj_utils Builds paths within the active project returned by
#'   `proj_get()`. Thin wrapper around [fs::path()].
#' @inheritParams fs::path
#' @export
proj_path <- function(..., ext = "") {
  has_absolute_path <- function(x) any(is_absolute_path(x))
  dots <- list(...)
  if (any(map_lgl(dots, has_absolute_path))) {
    ui_abort("Paths must be relative to the active project, not absolute.")
  }

  path_norm(path(proj_get(), ..., ext = ext))
}

#' @describeIn proj_utils Runs code with a temporary active project and,
#'   optionally, working directory. It is an example of the `with_*()` functions
#'   in [withr](https://withr.r-lib.org).
#' @param code Code to run with temporary active project
#' @param setwd Whether to also temporarily set the working directory to the
#'   active project, if it is not `NULL`
#' @param quiet Whether to suppress user-facing messages, while operating in the
#'   temporary active project
#' @export
with_project <- function(
  path = ".",
  code,
  force = FALSE,
  setwd = TRUE,
  quiet = getOption("usethis.quiet", default = FALSE)
) {
  local_project(path = path, force = force, setwd = setwd, quiet = quiet)
  force(code)
}

#' @describeIn proj_utils Sets an active project and, optionally, working
#'   directory until the current execution environment goes out of scope, e.g.
#'   the end of the current function or test.  It is an example of the
#'   `local_*()` functions in [withr](https://withr.r-lib.org).
#' @param .local_envir The environment to use for scoping. Defaults to current
#'   execution environment.
#' @export
local_project <- function(
  path = ".",
  force = FALSE,
  setwd = TRUE,
  quiet = getOption("usethis.quiet", default = FALSE),
  .local_envir = parent.frame()
) {
  withr::local_options(usethis.quiet = quiet, .local_envir = .local_envir)

  old_project <- proj_get_() # this could be `NULL`, i.e. no active project
  withr::defer(proj_set(path = old_project, force = TRUE), envir = .local_envir)
  proj_set(path = path, force = force)
  temp_proj <- proj_get_() # this could be `NULL`

  if (isTRUE(setwd) && !is.null(temp_proj)) {
    withr::local_dir(temp_proj, .local_envir = .local_envir)
  }
}

## usethis policy re: preparation of the path to active project
proj_path_prep <- function(path) {
  if (is.null(path)) {
    return(path)
  }
  path <- path_abs(path)
  if (file_exists(path)) {
    path_real(path)
  } else {
    path
  }
}

## usethis policy re: preparation of user-provided path to a resource on user's
## file system
user_path_prep <- function(path) {
  ## usethis uses fs's notion of home directory
  ## this ensures we are consistent about that
  path_expand(path)
}

proj_rel_path <- function(path) {
  if (is_in_proj(path)) {
    as.character(path_rel(path, start = proj_get()))
  } else {
    path
  }
}

proj_crit <- function() {
  rprojroot::has_file(".here") |
    rprojroot::is_rstudio_project |
    rprojroot::is_r_package |
    rprojroot::is_git_root |
    rprojroot::is_vscode_project |
    rprojroot::is_quarto_project |
    rprojroot::is_renv_project |
    rprojroot::is_remake_project |
    rprojroot::is_projectile_project
}

proj_find <- function(path = ".") {
  tryCatch(
    rprojroot::find_root(proj_crit(), path = path),
    error = function(e) NULL
  )
}

possibly_in_proj <- function(path = ".") !is.null(proj_find(path))

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

  message <- "Project {.val {project_name()}} is not an R package."
  if (!is.null(whos_asking)) {
    whos_asking_fn <- sub("()", "", whos_asking, fixed = TRUE)
    message <- c(
      "i" = "{.topic [{whos_asking}](usethis::{whos_asking_fn})} is designed to work with packages.",
      "x" = message
    )
  }
  ui_abort(message)
}

check_is_project <- function() {
  if (!possibly_in_proj()) {
    ui_abort(c(
      "We do not appear to be inside a valid project or package.",
      "Read more in the help for {.fun usethis::proj_get}."
    ))
  }
}

proj_active <- function() !is.null(proj_get_())

is_in_proj <- function(path) {
  if (!proj_active()) {
    return(FALSE)
  }
  identical(
    proj_get(),
    ## use path_abs() in case path does not exist yet
    path_common(c(proj_get(), path_expand(path_abs(path))))
  )
}

project_name <- function(base_path = proj_get()) {
  ## escape hatch necessary to solve this chicken-egg problem:
  ## create_package() calls use_description(), which calls project_name()
  ## to learn package name from the path, in order to make DESCRIPTION
  ## and DESCRIPTION is how we recognize a package as a usethis project
  if (!possibly_in_proj(base_path)) {
    return(path_file(base_path))
  }

  if (is_package(base_path)) {
    proj_desc(base_path)$get_field("Package")
  } else {
    path_file(base_path)
  }
}

#' Activate a project
#'
#' Activates a project in the usethis, R session, and (if relevant) RStudio
#' senses. If you are in RStudio, this will open a new RStudio session. If not, it will
#' change the working directory and [active project][proj_set()].
#'
#' * If using RStudio desktop, the project is opened in a new session.
#'   * If using Positron, the project is opened in a new window.
#'   * If using RStudio or Positron on a server, the project is opened in a new
#'     browser tab.
#'   * Otherwise, the working directory and active project is changed in the
#'     current R session.
#'
#' @param path Project directory
#' @return Single logical value indicating if current session is modified.
#' @export
proj_activate <- function(path) {
  check_path_is_directory(path)
  path <- user_path_prep(path)

  if (rstudio_available() && rstudioapi::hasFun("openProject")) {
    # TODO: Perhaps in future this message can be specialized for RStudio vs.
    # Positron. For now, I've just made it more generic to work better for both.
    ui_bullets(c(
      "v" = "Opening {.path {pth(path, base = NA)}} in a new session."
    ))
    rstudioapi::openProject(path, newSession = TRUE)
    invisible(FALSE)
  } else {
    proj_set(path)
    rel_path <- path_rel(proj_get(), path_wd())
    if (rel_path != ".") {
      ui_bullets(c(
        "v" = "Changing working directory to {.path {pth(path, base = NA)}}"
      ))
      setwd(proj_get())
    }
    invisible(TRUE)
  }
}
