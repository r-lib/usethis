#' Use pkgdown
#'
#' @description
#' [pkgdown](https://pkgdown.r-lib.org) makes it easy to turn your package into
#' a beautiful website. usethis provides two functions to help you use pkgdown:
#'
#' * `use_pkgdown()`: creates a pkgdown config file and adds relevant files or
#'   directories to `.Rbuildignore` and `.gitignore`.
#'
#' * `use_pkgdown_github_pages()`: implements the GitHub setup needed to
#'   automatically publish your pkgdown site to GitHub pages:
#'
#'   - (first, it calls `use_pkgdown()`)
#'   - [use_github_pages()] prepares to publish the pkgdown site from the
#'     `gh-pages` branch
#'   - [`use_github_action("pkgdown")`][use_github_action()] configures a
#'     GitHub Action to automatically build the pkgdown site and deploy it via
#'     GitHub Pages
#'   - The pkgdown site's URL is added to the pkgdown configuration file,
#'     to the URL field of DESCRIPTION, and to the GitHub repo.
#'   - Packages owned by certain GitHub organizations (tidyverse, r-lib, and
#'     tidymodels) get some special treatment, in terms of anticipating the
#'     (eventual) site URL and the use of a pkgdown template.
#'
#' `use_pkgdown_travis()` is deprecated; we no longer recommend that you use
#' Travis-CI.
#'
#' @seealso <https://pkgdown.r-lib.org/articles/pkgdown.html#configuration>
#' @param config_file Path to the pkgdown yaml config file
#' @param destdir Target directory for pkgdown docs
#' @export
use_pkgdown <- function(config_file = "_pkgdown.yml", destdir = "docs") {
  check_is_package("use_pkgdown()")
  check_installed("pkgdown")

  use_build_ignore(c(config_file, destdir, "pkgdown"))
  use_git_ignore(destdir)

  config <- pkgdown_config(destdir)
  config_path <- proj_path(config_file)
  write_over(config_path, yaml::as.yaml(config))
  edit_file(config_path)

  invisible(TRUE)
}

pkgdown_config <- function(destdir) {
  config <- list(
    url = NULL
  )

  if (pkgdown_version() >= "1.9000") {
    config$template <- list(bootstrap = 5L)
  }

  if (!identical(destdir, "docs")) {
    config$destination <- destdir
  }

  config
}

# wrapping because I need to be able to mock this in tests
pkgdown_version <- function() {
  utils::packageVersion("pkgdown")
}

#' @rdname use_pkgdown
#' @export
use_pkgdown_github_pages <- function() {
  tr <- target_repo(github_get = TRUE, ok_configs = c("ours", "fork"))
  # TODO: feels like there should be a can_push challenge here

  use_pkgdown()
  site <- use_github_pages()
  use_github_action("pkgdown")

  site_url <- tidyverse_url(url = site$html_url, tr = tr)
  use_pkgdown_url(url = site_url, tr = tr)

  if (is_rstudio_pkg()) {
    ui_done("
      Adding {ui_value('tidyverse/tidytemplate')} to \\
      {ui_field('Config/Needs/website')}")
    use_description_list("Config/Needs/website", "tidyverse/tidytemplate")
  }
}

# helpers ----------------------------------------------------------------------
use_pkgdown_url <- function(url, tr = NULL) {
  tr <- tr %||% target_repo(github_get = TRUE)

  config_path <- pkgdown_config_path()
  ui_done("
    Recording {ui_value(url)} as site's {ui_field('url')} in \\
    {ui_path(config_path)}")
  config <- pkgdown_config_meta()
  if (has_name(config, "url")) {
    config$url <- url
  } else {
    config <- c(url = url, config)
  }
  write_utf8(config_path, yaml::as.yaml(config))

  ui_done("Adding {ui_value(url)} to {ui_field('URL')} field in DESCRIPTION")
  desc <- desc::desc(file = proj_get())
  desc$add_urls(url)
  desc$write()
  if (has_package_doc()) {
    ui_todo("
      Run {ui_code('devtools::document()')} to update package-level documentation.")
  }

  gh <- gh_tr(tr)
  homepage <- gh("GET /repos/{owner}/{repo}")[["homepage"]]
  if (is.null(homepage) || homepage != url) {
    ui_done("Setting {ui_value(url)} as homepage of GitHub repo \\
      {ui_value(tr$repo_spec)}")
    gh("PATCH /repos/{owner}/{repo}", homepage = url)
  }

  invisible()
}

tidyverse_url <- function(url, tr = NULL) {
  tr <- tr %||% target_repo(github_get = TRUE)
  if (!is_interactive() ||
      !tr$repo_owner %in% c("tidyverse", "r-lib", "tidymodels")) {
    return(url)
  }

  custom_url <- glue("https://{tr$repo_name}.{tr$repo_owner}.org")
  if (grepl(glue("{custom_url}/?"), url)) {
    return(url)
  }
  if (ui_yeah("
    {ui_value(tr$repo_name)} is owned by the {ui_value(tr$repo_owner)} GitHub \\
    organization.
    Shall we configure {ui_value(custom_url)} as the (eventual) \\
    pkgdown URL?")) {
    custom_url
  } else {
    url
  }
}

pkgdown_config_path <- function() {
  path_first_existing(
    proj_path(
      c(
        "_pkgdown.yml",
        "_pkgdown.yaml",
        "pkgdown/_pkgdown.yml",
        "pkgdown/_pkgdown.yaml",
        "inst/_pkgdown.yml",
        "inst/_pkgdown.yaml"
      )
    )
  )
}

uses_pkgdown <- function() {
  !is.null(pkgdown_config_path())
}

pkgdown_config_meta <- function() {
  if (!uses_pkgdown()) {
    return(list())
  }
  path <- pkgdown_config_path()
  yaml::read_yaml(path) %||% list()
}

pkgdown_url <- function(pedantic = FALSE) {
  if (!uses_pkgdown()) {
    return(NULL)
  }

  meta <- pkgdown_config_meta()
  url <- meta$url
  if (!is.null(url)) {
    return(url)
  }

  if (pedantic) {
    ui_warn("
      pkgdown config does not specify the site's {ui_field('url')}, \\
      which is optional but recommended")
  }
    NULL
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

  use_build_ignore(c("docs/", "pkgdown"))
  use_git_ignore("docs/")
  # TODO: suggest git rm -r --cache docs/
  # Can't currently detect if git known files in that directory

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

  use_github_pages()

  invisible()
}
