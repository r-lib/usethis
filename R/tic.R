#' Set up CI with the tic package
#'
#' By default the CI-services "Travis" (Linux) and "Appveyor"
#' (Windows) will be set up. Basic `.travis.yml` and `appveyor.yml` files are
#' added to the top-level directory of a package.
#'
#' This function is aimed at supporting the most common use cases.
#' Users who require more control are advised to manually call the individual
#' functions.
#' @param services `[character]`\cr
#'   CI services to add, default: auto-detect.
#' @export
use_tic <- function(services = NULL) {
  check_installed("travis")

  path <- proj_get()

  #' @details
  #' The following steps will be run:
  withr::with_dir(path, {
    repo_type <- detect_repo_type()

    if (needs_deploy(repo_type)) {
      check_installed("tic")
      check_installed("openssl")
    }

    if (is.null(services)) {
      services <- c(
        "travis",
        if (needs_appveyor(repo_type)) "appveyor"
      )
    }

    #' 1. If necessary, create a GitHub repository via [use_github()]
    use_github()

    if ("travis" %in% services) {
      #' 1. Enable Travis via [travis::travis_enable()]
      travis::travis_enable()

      #' 1. Create a default `.travis.yml` file
      #'    (overwrite after confirmation in interactive mode only)
      use_template(
        "travis.yml",
        ".travis.yml",
        ignore = TRUE
      )
    }

    if ("appveyor" %in% services) {
      #' 1. Create a default `appveyor.yml` file
      #'    (if requested, by default only for packages, overwrite after confirmation
      #'    in interactive mode only)
      use_template(
        "appveyor.yml",
        "appveyor.yml",
        ignore = TRUE
      )
    }

    #' 1. Create a default `tic.R` file depending on the repo type
    #'    (package, website, bookdown, ...)
    use_template_tic(repo_type, "tic.R")

    #' 1. Enable deployment (if necessary, depending on repo type)
    #'    via [use_travis_deploy()]
    if (needs_deploy(repo_type)) {
      use_travis_deploy()
    }

    #' 1. Create a GitHub PAT and install it on Travis CI via [travis::travis_set_pat()]
    travis::travis_set_pat()
  })

  # Add badges at the end so that the instructions don't get lost in
  # in the rather verbose output
  if ("travis" %in% services) {
    use_travis_badge()
  }

  if ("appveyor" %in% services) {
    use_appveyor_badge()
  }
}

use_template_tic <- function(..., target = basename(file.path(...))) {
  template_path <- path("tic", ...)
  use_template(
    template_path,
    path_file(template_path),
    ignore = TRUE
  )
}

detect_repo_type <- function() {
  if (file_exists("_bookdown.yml")) return("bookdown")
  if (file_exists("_site.yml")) return("site")
  if (file_exists("config.toml")) return("blogdown")
  if (file_exists("DESCRIPTION")) return("package")
  "unknown"
}

needs_appveyor <- function(repo_type) {
  repo_type == "package"
}

needs_deploy <- function(repo_type) {
  repo_type != "unknown"
}
