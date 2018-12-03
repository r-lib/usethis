#' Use pkgdown
#'
#' [pkgdown](https://github.com/r-lib/pkgdown) makes it easy to turn your
#' package into a beautiful website. `use_pkgdown()` helper creates a pkgdown
#' config file and adds the file and destination directory to `.Rbuildignore`.
#' `use_pkgdown_travis()` helps you set up pkgdown for automatic deployment
#' on travis.
#'
#' @seealso <http://pkgdown.r-lib.org/articles/pkgdown.html#configuration>
#' @param config_file pkgdown yaml config file
#' @param destdir target directory for pkgdown docs
#' @export
use_pkgdown <- function(config_file = "_pkgdown.yml", destdir = "docs") {
  check_is_package("use_pkgdown()")
  check_installed("pkgdown")

  use_build_ignore(c(config_file, destdir))
  use_build_ignore("pkgdown")

  if (has_logo()) {
    pkgdown::build_favicon(proj_get())
  }

  config <- proj_path(config_file)
  write_over(config, paste("destination:", destdir))
  edit_file(config)

  invisible(TRUE)
}

#' @export
#' @rdname use_pkgdown
use_pkgdown_travis <- function() {
  check_installed("pkgdown")

  if (!uses_pkgdown()) {
    ui_stop(c(
      "Package doesn't use pkgdown.",
      "Do you need to call code('use_pkgdown())?"
    ))
  }

  use_build_ignore("docs/")

  if (has_logo()) {
    pkgdown::build_favicon(proj_get())
    use_build_ignore("pkgdown")
  }

  ui_todo("Set up deploy keys by running {ui_code('travis::use_travis_deploy()')}")
  ui_todo("Insert the following code in {ui_path('.travis.yml')}")
  ui_code_block(
    "
    before_deploy: Rscript -e 'remotes::install_cran(\"pkgdown\")'
    deploy:
      provider: script
      script: Rscript -e 'pkgdown::deploy_site_github()'
      skip_cleanup: true
    "
  )

  if (!git_branch_exists("gh-pages")) {
    ui_todo("Create gh-pages branch")
  }

  invisible()
}

uses_pkgdown <- function() {
  file_exists(proj_path("_pkgdown.yml")) ||
    file_exists(proj_path("pkgdown", "_pkgdown.yml"))
}
