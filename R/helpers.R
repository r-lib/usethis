#' Use a usethis template
#'
#' @param template Template name
#' @param save_as Name of file to create. Defaults to `save_as`
#' @param data A list of data passed to the template.
#' @param ignore Should the newly created file be added to `.Rbuildignore?`
#' @param open Should the new created file be opened in RStudio?
#' @return A logical vector indicating if file was modified.
#' @keywords internal
use_template <- function(template,
                         save_as = template,
                         data = list(),
                         ignore = FALSE,
                         open = FALSE) {

  template_contents <- render_template(template, data)
  new <- write_over(proj_get(), save_as, template_contents)

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open) {
    edit_file(proj_get(), save_as)
  }

  invisible(new)
}

render_template <- function(template, data = list()) {
  template_path <- find_template(template)
  paste0(whisker::whisker.render(readLines(template_path), data), "\n", collapse = "")
}

find_template <- function(template_name) {
  path <- system.file("templates", template_name, package = "usethis")
  if (identical(path, "")) {
    stop("Could not find template ", value(template_name), call. = FALSE)
  }
  path
}

is_package <- function(base_path = proj_get()) {
  file.exists(file.path(base_path, "DESCRIPTION"))
}

project_data <- function(base_path = proj_get()) {
  if (is_package(base_path)) {
    package_data(base_path)
  } else {
    list(Project = basename(base_path))
  }
}

package_data <- function(base_path = proj_get()) {
  desc <- desc::description$new(base_path)

  out <- as.list(desc$get(desc$fields()))
  if (uses_github(base_path)) {
    out$github <- gh::gh_tree_remote(base_path)
  }
  out
}

project_name <- function(base_path = proj_get()) {
  desc_path <- file.path(base_path, "DESCRIPTION")

  if (file.exists(desc_path)) {
    desc::desc_get("Package", base_path)[[1]]
  } else {
    basename(normalizePath(base_path, mustWork = FALSE))
  }
}

use_description_field <- function(name, value, base_path = proj_get(), overwrite = FALSE) {
  curr <- desc::desc_get(name, file = base_path)[[1]]
  if (identical(curr, value))
    return()

  if (is.na(curr) || overwrite) {
    done("Setting ", field(name), " field in DESCRIPTION to ", value(value))
    desc::desc_set(name, value, file = base_path)
  }
}

use_dependency <- function(package, type, version = "*") {
  stopifnot(is.character(package), length(package) == 1)
  stopifnot(is.character(type), length(type) == 1)

  if (package != "R" && !requireNamespace(package, quietly = TRUE)) {
    stop(package, " must be installed before you can take a dependency on it",
      call. = FALSE)
  }

  types <- c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)
  type <- types[[match.arg(tolower(type), names(types))]]

  deps <- desc::desc_get_deps(proj_get())

  matching_dep <- deps$package == package & deps$type == type
  to_add <- !any(matching_dep)
  to_set <- any(matching_dep & deps$version != version)

  if (to_add) {
    done("Adding ", value(package), " to ", field(type), " field in DESCRIPTION")
    desc::desc_set_dep(package, type, version = version, file = proj_get())
  } else if (to_set) {
    done("Setting ", value(package), " version to ", field(version), " field in DESCRIPTION")
    desc::desc_set_dep(package, type, version = version, file = proj_get())
  }

  invisible()
}

#' Use a directory.
#'
#' `use_directory()` creates a directory (if it does not already exist) in the
#' package root dir. This function powers many of the other `use_` functions
#' such as [use_data()] and [use_vignette()].
#'
#' @param path Path of the directory to create (relative to `base_path`).
#' @inheritParams use_template
#'
#' @export
#' @md
#' @examples
#' \dontrun{
#' use_directory("inst")
#' }
use_directory <- function(path,
                          ignore = FALSE) {


  if (!file.exists(file.path(proj_get(), path))) {
    done("Creating ", value(path, "/"))
  }
  create_directory(proj_get(), path)

  if (ignore) {
    use_build_ignore(path)
  }

  invisible(TRUE)
}

create_directory <- function(base_path, path) {
  if (!file.exists(base_path)) {
    stop(value(base_path), " does not exist", call. = FALSE)
  }
  pkg_path <- file.path(base_path, path)

  if (file.exists(pkg_path)) {
    if (!is_dir(pkg_path)) {
      stop(value(path), " exists but is not a directory.", call. = FALSE)
    }
  } else {
    ok <- dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE)

    if (!ok) {
      stop("Failed to create path", call. = FALSE)
    }
  }

  pkg_path
}

edit_file <- function(base_path, path) {
  full_path <- path.expand(file.path(base_path, path))

  if (!interactive()) {
    todo("Edit ", value(path))
  } else {
    if (!file.exists(full_path)) {
      file.create(full_path)
    }

    todo("Modify ", value(path))

    if (rstudioapi::isAvailable() && rstudioapi::hasFun("navigateToFile")) {
      rstudioapi::navigateToFile(full_path)
    } else {
      utils::file.edit(full_path)
    }
  }
  invisible()
}

view_url <- function(..., open = interactive()) {
  url <- paste(..., sep = "/")
  if (open) {
    done("Opening url")
    utils::browseURL(url)
  } else {
    todo("Open url ", url)
  }
  invisible()
}
