#' Create a CRAN badge
#'
#' This prints out the markdown which will display a CRAN "badge", indicating
#' what version of your package is available on CRAN, powered by
#' \url{(http://www.r-pkg.org}.
#'
#' @inheritParams use_template
#' @export
use_cran_badge <- function(base_path = ".") {
  pkg <- project_name(base_path)

  src <- paste0("http://www.r-pkg.org/badges/version/", pkg)
  href <- paste0("https://cran.r-project.org/package=", pkg)
  use_badge("CRAN status", href, src, base_path = base_path)

  invisible(TRUE)
}

#' Use a README badge
#'
#' @param badge_name Badge name. Used in error message and alt text
#' @param href,src Badge link and image src
#' @inheritParams use_template
#' @export
use_badge <- function(badge_name, href, src, base_path = ".") {
  if (has_badge(href, base_path)) {
    return(FALSE)
  }

  img <- paste0("![", badge_name, "](", src, ")")
  link <- paste0("[", img, "](", href, ")")

  todo("Add a ", badge_name, " badge by adding the following line to your README:")
  code_block(link)
}

has_badge <- function(href, base_path = ".") {
  readme_path <- file.path(base_path, "README.md")
  if (!file.exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path)
  any(grepl(href, readme, fixed = TRUE))

}
