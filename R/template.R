#' Use a usethis-style template
#'
#' Creates a file from data and a template found in a package. Provides control
#' over file name, the addition to `.Rbuildignore`, and opening the file for
#' inspection.
#'
#' This function can be used as the engine for a templating function in other
#' packages. The `template` argument is used along with the `package` argument
#' to determine the path to your template file; it will be expected at
#' `system.file("templates", template, package = package)`.
#'
#' To interpolate your data into the template, supply a list using
#' the `data` argument. Internally, this function uses
#' [whisker::whisker.render()] to combine your template file with your data.
#'
#' @param template Path to template file relative to `"templates"` directory
#'   within `package`; see details.
#' @param save_as Name of file to create. Defaults to `template`
#' @param data A list of data passed to the template.
#' @param ignore Should the newly created file be added to `.Rbuildignore`?
#' @param open Open the newly created file for editing? Happens in RStudio, if
#'   applicable, or via [utils::file.edit()] otherwise.
#' @param package Name of the package where the template is found.
#' @return A logical vector indicating if file was modified.
#' @export
#' @examples
#' \dontrun{
#'   # Note: running this will write `NEWS.md` to your working directory
#'   use_template(
#'     template = "NEWS.md",
#'     data = list(Package = "acme", Version = "1.2.3"),
#'     package = "usethis"
#'   )
#' }
use_template <- function(template,
                         save_as = template,
                         data = list(),
                         ignore = FALSE,
                         open = FALSE,
                         package = "usethis") {
  template_contents <- render_template(template, data, package = package)
  new <- write_over(proj_path(save_as), template_contents)

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}

render_template <- function(template, data = list(), package = "usethis") {
  template_path <- find_template(template, package = package)
  strsplit(whisker::whisker.render(readLines(template_path), data), "\n")[[1]]
}

find_template <- function(template_name, package = "usethis") {
  path <- system.file("templates", template_name, package = package)
  if (identical(path, "")) {
    stop_glue(
      "Could not find template {value(template_name)}",
      " in package {value(package)}."
    )
  }
  path
}
