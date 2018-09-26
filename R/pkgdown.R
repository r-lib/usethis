#' Use pkgdown
#'
#' [pkgdown](https://github.com/hadley/pkgdown) makes it easy to turn your
#' package into a beautiful website. This helper creates `_pkgdown.yml`
#' and `docs/` for you, and adds them to `.Rbuildignore`
#'
#' @param config_file pkgdown yaml config file
#' @param build_dir target directory for pkgdown docs
#'
#' @export
use_pkgdown <- function(config_file = "_pkgdown.yml", build_dir = "docs") {
  check_is_package("use_pkgdown()")
  edit_file(proj_path(config_file))
  use_build_ignore(config_file)

  use_directory(build_dir, ignore = TRUE)
}
