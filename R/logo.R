#' Use a package logo
#'
#' This function helps you use a logo in your package:
#'   * Enforces a specific size
#'   * Stores logo image file at `man/figures/logo.png`
#'   * Produces the markdown text you need in README to include the logo
#'
#' @param img The path to an existing image file
#' @param geometry a [magick::geometry] string specifying size. The default
#'   assumes that you have a hex logo using spec from
#'   <http://hexb.in/sticker.html>.
#' @param retina `TRUE`, the default, scales the image on the README,
#'   assuming that geometry is double the desired size.
#'
#' @examples
#' \dontrun{
#' use_logo("usethis.png")
#' }
#' @export
use_logo <- function(img, geometry = "240x278", retina = TRUE) {
  check_is_package("use_logo()")

  logo_path <- proj_path("man", "figures", "logo", ext = path_ext(img))
  create_directory(path_dir(logo_path))
  if (!can_overwrite(logo_path)) {
    return(invisible(FALSE))
  }

  if (path_ext(img) == "svg") {
    logo_path <- path("man", "figures", "logo.svg")
    file_copy(img, proj_path(logo_path))
    ui_done("Copied {ui_path(img)} to {ui_path(logo_path)}")

    height <- as.integer(sub(".*x", "", geometry))
  } else {
    check_installed("magick")

    img_data <- magick::image_read(img)
    img_data <- magick::image_resize(img_data, geometry)
    magick::image_write(img_data, logo_path)
    ui_done("Resized {ui_path(img)} to {geometry}")

    height <- magick::image_info(magick::image_read(logo_path))$height
  }

  pkg <- project_name()
  if (retina) {
    height <- round(height / 2)
  }

  ui_todo("Add logo to your README with the following html:")
  pd_link <- pkgdown_url(pedantic = TRUE)
  if (is.null(pd_link)) {
    ui_code_block("# {pkg} <img src={ui_path(logo_path)} align=\"right\" height=\"{height}\" />")
  } else {
    ui_code_block("# {pkg} <a href={ui_value(pd_link)}><img src={ui_path(logo_path)} align=\"right\" height=\"{height}\" /></a>")
  }
}

has_logo <- function() {
  file_exists(proj_path("man", "figures", "logo.png")) ||
    file_exists(proj_path("man", "figures", "logo.svg"))
}
