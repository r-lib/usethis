#' Use pkgdown
#'
#' [pkgdown](https://github.com/r-lib/pkgdown) makes it easy to turn your
#' package into a beautiful website. This helper creates a pkgdown config file
#' and adds the file and destination directory to `.Rbuildignore`
#'
#' @seealso http://pkgdown.r-lib.org/articles/pkgdown.html#configuration
#'
#' @param config_file pkgdown yaml config file
#' @param dst_path target directory for pkgdown docs
#'
#' @export
use_pkgdown <- function(config_file = "_pkgdown.yml", destdir = "docs") {
  check_is_package("use_pkgdown()")
  use_build_ignore(c(config_file, destdir))

  config <- proj_path(config_file)

  write_over(config, paste("destination:", destdir))

  edit_file(config)
}
