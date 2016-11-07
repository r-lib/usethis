#' Use a usethis template
#'
#' @param template Template name
#' @param save_as Name of file to create. Defaults to \code{save_as}
#' @param data A list of data passed to the template.
#' @param ignore Should the newly created file be added to \code{.Rbuildignore?}
#' @param open Should the new created file be opened in RStudio?
#' @param base_path Path to package root.
#' @keywords internal
use_template <- function(template,
                         save_as = template,
                         data = list(),
                         ignore = FALSE,
                         open = FALSE,
                         base_path = "."
                         ) {

  render_template(template, save_as, data = data, base_path = base_path)

  if (ignore) {
    use_build_ignore(save_as, base_path = base_path)
  }

  if (open) {
    message("* Modify '", save_as, "'.")
    open_in_rstudio(save_as, base_path = base_path)
  }

  invisible(TRUE)
}

render_template <- function(template_name,
                            save_as = template_name,
                            data = list(),
                            base_path = ".") {
  template_path <- find_template(template_name)

  path <- file.path(base_path, save_as)
  if (!can_overwrite(path)) {
    stop("'", save_as, "' already exists.", call. = FALSE)
  }

  message("* Creating `", save_as, "` from template.")
  template <- whisker::whisker.render(readLines(template_path), data)
  writeLines(template, path)
}

find_template <- function(template_name) {
  path <- system.file("templates", template_name, package = "usethis")
  if (identical(path, "")) {
    stop("Could not find template '", template_name, "'", call. = FALSE)
  }
  path
}

package_data <- function(base_path = ".") {
  desc <- desc::description$new(base_path)

  out <- as.list(desc$get(desc$fields()))
  if (uses_github(base_path)) {
    out$github <- github_info(base_path)
  }
  out
}

project_name <- function(base_path = ".") {
  desc_path <- file.path(base_path, "DESCRIPTION")

  if (file.exists(desc_path)) {
    desc::desc_get("Package", base_path)[[1]]
  } else {
    basename(normalizePath(base_path))
  }
}

use_description_field <- function(name, value, base_path = ".", overwrite = FALSE) {
  path <- file.path(base_path, "DESCRIPTION")

  curr <- desc::desc_get(name, file = path)[[1]]
  if (identical(curr, value))
    return()

  if (is.null(curr) || overwrite) {
    message("* Setting ", name, " to ", value, ".")
    desc::desc_set(name, value, file = path)
  } else {
    message("* Preserving existing field ", name)
  }
}

use_dependency <- function(package, type, base_path = ".") {
  stopifnot(is.character(package), length(package) == 1)
  stopifnot(is.character(type), length(type) == 1)

  if (!requireNamespace(package, quietly = TRUE)) {
    stop(package, " must be installed before you can take a dependency on it",
      call. = FALSE)
  }

  types <- c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)
  type <- types[[match.arg(tolower(type), names(types))]]

  deps <- desc::desc_get_deps(base_path)
  has_dep <- any(deps$package == package & deps$type == type)
  if (!has_dep) {
    message("* Adding ", package, " to ", type, ".")
    desc::desc_set_dep(package, type, file = file.path(base_path, "DESCRIPTION"))
  }

  invisible()
}

use_directory <- function(path, ignore = FALSE, base_path = ".") {
  pkg_path <- file.path(base_path, path)

  if (file.exists(pkg_path)) {
    if (!is_dir(pkg_path)) {
      stop("'", path, "' exists but is not a directory.", call. = FALSE)
    }
  } else {
    message("* Creating '", path, "'.")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE)
  }

  if (ignore) {
    use_build_ignore(path, base_path = base_path)
  }

  invisible(TRUE)
}

union_write <- function(path, new_lines, quiet = FALSE) {
  stopifnot(is.character(new_lines))

  if (file.exists(path)) {
    lines <- readLines(path, warn = FALSE)
  } else {
    lines <- character()
  }

  new <- setdiff(new_lines, lines)
  if (!quiet && length(new) > 0) {
    quoted <- paste0("'", new, "'", collapse = ", ")
    message("* Adding ", quoted, " to '", basename(path), "'.")
  }

  all <- union(lines, new_lines)
  writeLines(all, path)
}

open_in_rstudio <- function(path, base_path = ".") {
  path <- file.path(base_path, path)

  if (!rstudioapi::isAvailable())
    return()

  if (!rstudioapi::hasFun("navigateToFile"))
    return()

  rstudioapi::navigateToFile(path)
}
