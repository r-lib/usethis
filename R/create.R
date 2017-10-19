#' Create a new package or project
#'
#' Both functions change the active project so that subsequent `use_` calls
#' will affect the project that you've just created. See `proj_set()` to
#' manually reset it.
#'
#' @param path A path. If it exists, it will be used. If it does not
#'   exist, it will be created (providing that the parent path exists).
#' @param rstudio If `TRUE`, run [use_rstudio()].
#' @param open If `TRUE`, will automatically open
#' @inheritParams use_description
#' @export
create_package <- function(path = ".",
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
    if (rstudio) {
      done("Opening project in new session")
      project_path <- file.path(normalizePath(path), paste0(name, ".Rproj"))
      utils::browseURL(project_path)
    } else {
      setwd(path)
      done("Changing working directory to ", value(path))
    }
  }

  invisible(TRUE)
}

#' @export
#' @rdname create_package
create_project <- function(path = ".",
                           open = interactive()) {

  path <- normalizePath(path, mustWork = FALSE)

  name <- basename(path)
  check_not_nested(dirname(path), name)

  create_directory(dirname(path), name)
  cat_line(crayon::bold("Changing active project to", crayon::red(name)))
  proj_set(path, force = TRUE)

  use_rstudio()
  use_directory("R")

  if (open) {
    done("Opening project in new session")
    project_path <- file.path(normalizePath(path), paste0(name, ".Rproj"))
    utils::browseURL(project_path)
  }

  invisible(TRUE)
}


check_not_nested <- function(path, name) {
  proj_root <- proj_find(path)

  if (is.null(proj_root))
    return()

  message <- paste0(
    "New project ", value(name), " is nested inside an existing project ",
    value(proj_root), "."
  )
  if (!interactive()) {
    stop(message, call. = FALSE)
  }

  if (yesno(message, " This is rarely a good idea. Do you wish to create anyway?")) {
    stop("Aborting project creation", call. = FALSE)
  }

}
