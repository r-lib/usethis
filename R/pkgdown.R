#' Use pkgdown
#'
#' [pkgdown](https://pkgdown.r-lib.org) makes it easy to turn your package into
#' a beautiful website. A couple functions help you begin to use pkgdown:
#'   * `use_pkgdown()`: creates a pkgdown config file, adds relevant files or
#'     directories to `.Rbuildignore` and `.gitignore`, and builds favicons if
#'     your package has a logo.
#'   * `use_github_action("pkgdown")` configures a GitHub Actions workflow to
#'     build and deploy your pkgdown site whenever you push changes to GitHub.
#'     Learn more about [use_github_action()]. This approach is actively
#'     maintained, because it is in use across many tidyverse, r-lib, and
#'     tidymodels packages.
#'   * `use_pkgdown_travis()` \lifecycle{soft-deprecated} helps you set up
#'     pkgdown for automatic deployment on Travis-CI. This is soft-deprecated,
#'     as the tidyverse team has shifted away from Travis-CI and towards GitHub
#'     Actions. `use_pkgdown_travis()` creates an empty `gh-pages` branch for
#'     the site and prompts about next steps regarding deployment keys and
#'     updating your `.travis.yml`. Requires that the current user can push to
#'     the primary repo, which must be configured as the `origin` remote.
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

  ui_todo("
    Record your site's {ui_field('url')} in the pkgdown config file \\
    (optional, but recommended)")

  if (has_logo()) {
    pkgdown_build_favicons(proj_get(), overwrite = TRUE)
  }

  config <- proj_path(config_file)
  if (!identical(destdir, "docs")) {
    write_over(config, paste("destination:", destdir))
  }
  edit_file(config)

  invisible(TRUE)
}

# tidyverse pkgdown setup ------------------------------------------------------

#' @details
#' * `use_tidy_pkgdown()`: Implements the pkgdown setup favored by the
#'   tidyverse team:
#'   - [use_pkgdown()] does basic local setup
#'   - [use_github_pages()] prepares to publish the pkgdown site from the
#'     `github-pages` branch
#'   - [use_github_action("pkgdown")] configures a GitHub Action to
#'     automatically build the pkgdown site and deploy it via GitHub Pages
#'   - The pkgdown website URL (if specified or inferred) is added to the
#'     pkgdown configuration file and to the URL field of DESCRIPTION
#'
#' @param cname Optional, custom domain name. If the target repo belongs to the
#'   tidyverse or r-lib GitHub organizations, this is formed automatically.
#'
#' @rdname tidyverse
#' @export
use_tidy_pkgdown <- function(cname = NULL) {
  tr <- target_repo(github_get = TRUE)
  cname <- cname %||% default_cname(tr) %||% NA
  stopifnot(is.na(cname) || is_string(cname))
  cname <- sub("^https?://(.*)$", "\\1", cname)

  use_pkgdown()
  use_github_pages(cname = cname)
  use_github_action("pkgdown")

  if (is.na(cname)) {
    return(invisible())
  }
  pkgdown_url <- paste0("https://", cname)

  config <- pkgdown_config_path()
  ui_done("
    Recording pkgdown URL ({ui_value(pkgdown_url)}) in {ui_path(config)}")
  config_lines <- read_utf8(config)
  config_lines <- config_lines[!grepl("^url:", config_lines)]
  write_over(config, c(
    paste("url:", pkgdown_url),
    if (nzchar(config_lines[1])) "",
    config_lines
  ))

  urls <- desc::desc_get_urls()
  if (!pkgdown_url %in% urls) {
    ui_done("Adding pkgdown site to {ui_field('URL')} field in DESCRIPTION")
    ui_silence(
      use_description_field(
        "URL",
        glue_collapse(c(pkgdown_url, urls), ", "),
        overwrite = TRUE
      )
    )
  }

  gh <- function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      owner = tr$repo_owner, repo = tr$repo_name, .api_url = tr$api_url
    )
  }
  homepage <- gh("GET /repos/{owner}/{repo}")[["homepage"]]
  if (is.null(homepage) || homepage != pkgdown_url) {
    ui_done("Setting homepage of {ui_value(tr$repo_spec)} to pkgdown site")
    gh::gh(
      "PATCH /repos/{owner}/{repo}",
      homepage = pkgdown_url,
      owner = tr$repo_owner, repo = tr$repo_name, .api_url = tr$api_url
    )
  }

  invisible()

}

# helpers ----------------------------------------------------------------------
default_cname <- function(tr) {
  if (!tr$repo_owner %in% c("tidyverse", "r-lib")) {
    return()
  }

  glue("{tr$repo_name}.{tr$repo_owner}.org")
}

pkgdown_config_path <- function(base_path = proj_get()) {
  path_first_existing(
    base_path,
    c(
      "_pkgdown.yml",
      "_pkgdown.yaml",
      "pkgdown/_pkgdown.yml",
      "inst/_pkgdown.yml"
    )
  )
}

uses_pkgdown <- function(base_path = proj_get()) {
  !is.null(pkgdown_config_path(base_path))
}

pkgdown_config_meta <- function(base_path = proj_get()) {
  if (!uses_pkgdown(base_path)) {
    return(list())
  }
  path <- pkgdown_config_path(base_path)
  yaml::read_yaml(path) %||% list()
}

pkgdown_url <- function(base_path = proj_get(), pedantic = FALSE) {
  if (!uses_pkgdown(base_path)) {
    return(NULL)
  }

  meta <- pkgdown_config_meta(base_path)
  url <- meta$url
  if (is.null(url)) {
    if (pedantic) {
      ui_warn("
        pkgdown config does not specify the site's {ui_field('url')}, \\
        which is optional but recommended")
    }
    NULL
  } else {
    gsub("/$", "", url)
  }
}

# travis ----

#' @export
#' @rdname use_pkgdown
use_pkgdown_travis <- function() {
  lifecycle::deprecate_soft(
    when = "2.0.0",
    what = "usethis::use_pkgdown_travis()",
    details = 'We recommend `use_github_action("pkgdown")` for new pkgdown setups.'
  )
  check_installed("pkgdown")
  if (!uses_pkgdown()) {
    ui_stop("
      Package doesn't use pkgdown.
      Do you need to call {ui_code('use_pkgdown()')}?")
  }

  tr <- target_repo(github_get = TRUE)

  use_build_ignore("docs/")
  use_git_ignore("docs/")
  # TODO: suggest git rm -r --cache docs/
  # Can't currently detect if git known files in that directory

  if (has_logo()) {
    pkgdown_build_favicons(proj_get(), overwrite = TRUE)
    use_build_ignore("pkgdown")
  }

  ui_todo("
    Set up deploy keys by running {ui_code('travis::use_travis_deploy()')}")
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

  if (!gert::git_branch_exists("origin/gh-pages", local = FALSE, repo = git_repo())) {
    create_gh_pages_branch(tr)
  }

  # TODO: actually do this
  ui_todo("
    Turn on GitHub pages at \\
    <https://github.com/{tr$repo_spec}/settings> (using gh-pages as source)")

  invisible()
}

# usethis itself should not depend on pkgdown
# all usage of this wrapper is guarded by `check_installed("pkgdown")`
pkgdown_build_favicons <- function(...) {
  get("build_favicons", asNamespace("pkgdown"), mode = "function")(...)
}
