#' Setup a complete package
#'
#' @param path A path. If it exists, it will be used. If it does not
#'   exist, it will be created (providing that the parent path exists).
#' @param rstudio If `TRUE`, run [use_rstudio()].
#' @param open If `TRUE`, will automatically open
#' @inheritParams use_description
#' @export
create_package <- function(path,
                           fields = getOption("devtools.desc"),
                           rstudio = rstudioapi::isAvailable(),
                           open = interactive()) {

  name <- basename(normalizePath(path, mustWork = FALSE))
  check_package_name(name)

  create_directory(dirname(path), name)
  cat_line(crayon::bold("Changing active project to", crayon::red(name)))
  proj_set(path)

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
      todo("Please change working directory to ", value(path))
    }
  }

  invisible(TRUE)
}
