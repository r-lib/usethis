#' Use a package logo
#'
#' This function helps you use a logo in your package:
#'   * Enforces a specific size
#'   * Stores logo image file at `man/figures/logo.png`
#'   * Produces the markdown text you need in README to include the logo
#'
#' @param img The path to an existing image file
#' @param geometry a [magick::geometry] string specifying size
#'
#' @examples
#' \dontrun{
#' use_logo("usethis.png")
#' }
#' @export
use_logo <- function(img, geometry = "120x140") {
  if (has_logo()) {
    return(invisible(FALSE))
  }

  check_installed("magick")
  check_is_package("use_logo()")

  img_data <- magick::image_read(img)
  img_data <- magick::image_resize(img_data, geometry)

  dir_create(proj_path("man", "figures"))
  magick::image_write(img_data, proj_path("man", "figures", "logo.png"))

  done("Resized {value(path_file(img))} to {geometry}")

  todo("Add a logo by adding the following line to your README:")
  pkg <- project_name()
  code_block("# {pkg} <img src=\"man/figures/logo.png\" align=\"right\" />")
}

has_logo <- function() {
  readme_path <- proj_path("README.md")
  if (!file_exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path)
  any(grepl("<img src=\"man/figures/logo.png\" align=\"right\" />", readme, fixed = TRUE))
}
