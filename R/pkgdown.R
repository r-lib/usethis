#' Use pkgdown
#'
#' [pkgdown](https://pkgdown.r-lib.org) makes it easy to turn your package into
#' a beautiful website. There are two helper functions:
#'   * `use_pkgdown()`: creates a pkgdown config file, adds relevant files or
#'     directories to `.Rbuildignore` and `.gitignore`, and builds favicons if
#'     your package has a logo
#'   * `use_pkgdown_travis()`: helps you set up pkgdown for automatic deployment
#'     on Travis-CI. As part of a general pivot away from Travis-CI and towards
#'     GitHub Actions, the tidyverse team now builds pkgdown sites with a
#'     workflow configured via `use_github_action("pkgdown")`.
#'     `use_pkgdown_travis()` is still here, but is no longer actively exercised
#'     by us. Key steps:
#'       - Creates an empty `gh-pages` branch for the pkgdown site to be
#'         deployed to.
#'       - Prompts you about what to do next regarding Travis-CI deployment
#'         keys and updating your `.travis.yml`.
#'
#' @seealso <https://pkgdown.r-lib.org/articles/pkgdown.html#configuration>
#' @param config_file Path to the pkgdown yaml config file
#' @param destdir Target directory for pkgdown docs
#' @export
use_pkgdown <- function(config_file = "_pkgdown.yml", destdir = "docs") {
  check_is_package("use_pkgdown()")
  check_installed("pkgdown")

  use_build_ignore(c(config_file, destdir))
  use_build_ignore("pkgdown")
  use_git_ignore(destdir)

  if (has_logo()) {
    pkgdown::build_favicons(proj_get(), overwrite = TRUE)
  }

  config <- proj_path(config_file)
  if (!identical(destdir, "docs")) {
    write_over(config, paste("destination:", destdir))
  }
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
      "Do you need to call {ui_code('use_pkgdown()')}?"
    ))
  }

  use_build_ignore("docs/")
  use_git_ignore("docs/")
  # TODO: suggest git rm -r --cache docs/
  # Can't currently detect if git known files in that directory

  if (has_logo()) {
    pkgdown::build_favicons(proj_get(), overwrite = TRUE)
    use_build_ignore("pkgdown")
  }

  ui_todo("Set up deploy keys by running {ui_code('travis::use_travis_deploy()')}")
  ui_todo("Insert the following code in {ui_path('.travis.yml')}")
  ui_code_block(
    "
    before_cache: Rscript -e 'remotes::install_cran(\"pkgdown\")'
    deploy:
      provider: script
      script: Rscript -e 'pkgdown::deploy_site_github()'
      skip_cleanup: true
    "
  )

  if (!git_branch_exists("origin/gh-pages")) {
    create_gh_pages_branch()
  }

  ui_todo("Turn on GitHub pages at <{github_home()}/settings> (using gh-pages as source)")

  invisible()
}

create_gh_pages_branch <- function() {
  ui_done("Initializing empty gh-pages branch")

  # git hash-object -t tree /dev/null.
  sha_empty_tree <- "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

  # Create commit with empty tree
  res <- gh::gh("POST /repos/:owner/:repo/git/commits",
    owner = github_owner(),
    repo = github_repo(),
    message = "first commit",
    tree = sha_empty_tree
  )

  # Assign ref to above commit
  gh::gh(
    "POST /repos/:owner/:repo/git/refs",
    owner = github_owner(),
    repo = github_repo(),
    ref = "refs/heads/gh-pages",
    sha = res$sha
  )
}

uses_pkgdown <- function() {
  file_exists(proj_path("_pkgdown.yml")) ||
    file_exists(proj_path("pkgdown", "_pkgdown.yml"))
}

pkgdown_link <- function() {
  if (!uses_pkgdown()) {
    return(NULL)
  }

  path <- proj_path("_pkgdown.yml")

  yaml <- yaml::yaml.load_file(path) %||% list()

  if (is.null(yaml$url)) {
    ui_warn("
      Package does not provide a pkgdown URL.
      Set one in the `url:` field of `_pkgdown.yml`"
    )
    return(NULL)
  }

  gsub("/$", "", yaml$url)
}
