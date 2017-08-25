#' Setup a complete package
#'
#' @param path A path. If it exists, it will be used. If it does not
#'   exist, it will be created (providing that the parent path exists).
#' @param rstudio If \code{TRUE}, run \code{\link{use_rstudio}}.
#' @inheritParams use_description
#' @export
create_package <- function(path,
                           fields = getOption("devtools.desc"),
                           rstudio = TRUE) {

  name <- basename(path)
  check_package_name(name)

  use_directory(name, base_path = dirname(path))
  use_directory("R", base_path = path)
  use_directory("man", base_path = path)

  use_description(fields = fields, base_path = path)
  use_namespace(base_path = path)

  if (rstudio) {
    use_rstudio(base_path = path)
    utils::browseURL(
      file.path(normalizePath(path), paste0(name, ".Rproj")))
  }

  invisible(TRUE)
}
