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
  logo_path <- proj_path("man", "figures", "logo", ext = path_ext(img))
  if (!can_overwrite(logo_path)) {
    return(invisible(FALSE))
  }

  dir_create(path_dir(logo_path))

  if (path_ext(img) == "svg") {
    logo_path <- path("man", "figures", "logo.svg")
    file_copy(img, proj_path(logo_path))

  } else {
    check_installed("magick")
    check_is_package("use_logo()")

    img_data <- magick::image_read(img)
    img_data <- magick::image_resize(img_data, geometry)

    logo_path <- path("man", "figures", "logo.png")

    magick::image_write(img_data, proj_path(logo_path))

    done("Resized {value(path_file(img))} to {geometry}")
  }

  pkg <- project_name()
  height <- as.integer(sub(".*x", "", geometry))

  todo("Add a logo by adding the following line to your README:")
  code_block("# {pkg} <img src=\"{logo_path}\" align=\"right\" height={height}/>")
}
