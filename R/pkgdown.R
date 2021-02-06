#' Use pkgdown
#'
#' @description
#' [pkgdown](https://pkgdown.r-lib.org) makes it easy to turn your package into
#' a beautiful website. usethis provides two functions help you use pkgdown:
#'
#' * `use_pkgdown()`: creates a pkgdown config file, adds relevant files or
#'   directories to `.Rbuildignore` and `.gitignore`, and builds favicons if
#'   your package has a logo.
#'
#' * `use_pkgdown_github_pages()`: implements the GitHub setup needed to
#'   automatically publish your pkgdown site to GitHub pages:
#'
#'   - [use_github_pages()] prepares to publish the pkgdown site from the
#'     `github-pages` branch
#'   - [`use_github_action("pkgdown")`][use_github_action()] configures a
#'     GitHub Action to automatically build the pkgdown site and deploy it via
#'     GitHub Pages
#'   - The pkgdown site's URL is added to the pkgdown configuration file,
#'     to the URL field of DESCRIPTION, and to the GitHub repo.
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

#' @rdname use_pkgdown
#' @export
use_pkgdown_github_pages <- function() {
  tr <- target_repo(github_get = TRUE)

  use_pkgdown()
  site <- use_github_pages()
  use_github_action("pkgdown")

  site_url <- sub("/$", "", site$html_url)
  site_url <- tidyverse_url(url = site_url, tr = tr)
  use_pkgdown_url(url = site_url, tr = tr)
}

# helpers ----------------------------------------------------------------------
use_pkgdown_url <- function(url, tr = NULL) {
  tr <- tr %||% target_repo(github_get = TRUE)

  config <- pkgdown_config_path()
  config_lines <- read_utf8(config)
  url_line <- paste0("url: ", url)
  if (!any(grepl(url_line, config_lines))) {
    ui_done("
      Recording {ui_value(url)} as site's {ui_field('url')} in \\
      {ui_path(config)}")
    config_lines <- config_lines[!grepl("^url:", config_lines)]
    write_utf8(config, c(
      url_line,
      if (length(config_lines) && nzchar(config_lines[[1]])) "",
      config_lines
    ))
  }

  urls <- desc::desc_get_urls()
  if (!url %in% urls) {
    ui_done("Adding {ui_value(url)} to {ui_field('URL')} field in DESCRIPTION")
    ui_silence(
      use_description_field(
        "URL",
        glue_collapse(c(url, urls), ", "),
        overwrite = TRUE
      )
    )
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
  if (!is_interactive() || !tr$repo_owner %in% c("tidyverse", "r-lib")) {
    return(url)
  }
  custom_url <- glue("https://{tr$repo_name}.{tr$repo_owner}.org")
  if (url == custom_url) {
    return(url)
  }
  if (ui_yeah("
    {ui_value(tr$repo_name)} is owned by the {ui_value(tr$repo_owner)} GitHub \\
    organization
    Shall we configure {ui_value(custom_url)} as the (eventual) \\
    pkgdown URL?")) {
    custom_url
  } else {
    url
  }
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

  use_github_pages()

  invisible()
}

# usethis itself should not depend on pkgdown
# all usage of this wrapper is guarded by `check_installed("pkgdown")`
pkgdown_build_favicons <- function(...) {
  get("build_favicons", asNamespace("pkgdown"), mode = "function")(...)
}
