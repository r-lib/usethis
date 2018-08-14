#' Use pkgdown
#'
#' [pkgdown](https://github.com/hadley/pkgdown) makes it easy to turn your
#' package into a beautiful website. This helper creates `_pkgdown.yml`
#' and `docs/` for you, and adds them to `.Rbuildignore`
#'
#' @export
use_pkgdown <- function() {
  check_is_package("use_pkgdown()")
  edit_file(proj_path("_pkgdown.yml"))
  use_build_ignore("_pkgdown.yml")

  use_directory("docs", ignore = TRUE)
}
