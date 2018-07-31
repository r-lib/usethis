#' Continuous integration setup and badges
#'
#' Sets up continuous integration (CI) services for an R package that is
#' developed on GitHub with CI-agnostic support by \pkg{tic}.
#' CI services can run `R CMD check` automatically on
#' various platforms, triggered by each push or pull request. This function
#' * Adds service-specific configuration files and adds them to `.Rbuildignore`.
#' * Activates a service or gives the user a detailed prompt.\cr
#' @name ci
NULL

#' @section `use_ci()`:
#' By default the CI-services "Travis" (Linux) and "Appveyor"
#' (Windows) will be set up. Basic `.travis.yml` and `appveyor.yml` files are
#' added to the top-level directory of a package.
#'
#' This function is aimed at supporting the most common use cases.
#' Users who require more control are advised to manually call the individual
#' functions.
#' @importFrom travis travis_set_pat
#' @param path `[string]`\cr
#'   The path to the repo to prepare.
#' @param quiet `[flag]`\cr
#'   Less verbose output? Default: `FALSE`.
#' @param services `[character]`\cr
#'   CI services to add.
#' @export
#' @rdname ci
use_ci <- function(path = ".", quiet = FALSE,
                   services = c("travis", "appveyor")) {
  #' @details
  #' The following steps will be run (`use_ci()` only):
  withr::with_dir(path, {
    #' 1. If necessary, create a GitHub repository via [use_github()]
    use_github()

    if ("travis" %in% services) {
      #' 1. Enable Travis via [travis_enable()]
      travis_enable()

      #' 1. Create a default `.travis.yml` file
      #'    (overwrite after confirmation in interactive mode only)
      use_template(
        "travis.yml",
        ".travis.yml",
        ignore = TRUE
      )
    }

    repo_type <- detect_repo_type()

    if ("appveyor" %in% services) {
      #' 1. Create a default `appveyor.yml` file
      #'    (depending on repo type, overwrite after confirmation
      #'    in interactive mode only)
      if (travis:::needs_appveyor(repo_type)) travis:::use_appveyor_yml() #FIXME: Export function in travis
    }

    #' 1. Create a default `tic.R` file depending on the repo type
    #'    (package, website, bookdown, ...)
    use_tic(repo_type)

    #' 1. Enable deployment (if necessary, depending on repo type)
    #'    via [use_travis_deploy()]
    if (travis:::needs_deploy(repo_type)) use_travis_deploy() #FIXME: Export function in travis

    #' 1. Create a GitHub PAT and install it on Travis CI via [travis_set_pat()]
    travis_set_pat()
  })
}

#' @section `use_travis()`:
#' Adds a basic `.travis.yml` to the top-level directory of a package. This is a
#' configuration file for the [Travis CI](https://travis-ci.org/) continuous
#' integration service.
#' @param browse Open a browser window to enable automatic builds for the
#'   package.
#' @export
#' @rdname ci
use_travis <- function(browse = interactive()) {

  warning("`use_travis()` is deprecated. Please use `use_ci()` in the future.")

  check_uses_github()

  use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE
  )

  travis_activate(browse)
  use_travis_badge()

  invisible(TRUE)
}

#' @section `use_appveyor()`:
#' Adds a basic `appveyor.yml` to the top-level directory of a package. This is
#' a configuration file for the [AppVeyor](https://www.appveyor.com) continuous
#' integration service for Windows.
#' @export
#' @rdname ci
use_appveyor <- function(browse = interactive()) {

  warning("`use_appveyor()` is deprecated. Please use `use_ci()` in the future.")

  check_uses_github()

  use_template("appveyor.yml", ignore = TRUE)

  appveyor_activate(browse)
  use_appveyor_badge()

  invisible(TRUE)
}

travis_activate <- function(browse = interactive()) {
  url <- glue("https://travis-ci.org/profile/{github_owner()}")
  todo("Turn on travis for your repo at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}

check_uses_travis <- function(base_path = proj_get()) {
  if(isTRUE(travis::travis_is_enabled())) {
    return(invisible())
  } else {
    stop(glue("Travis is not enabled for this repo. Please use",
              " `use_ci(services = 'travis')` to activate it."))
  }
}

use_tic <- function(repo_type) {
  use_template_tic(repo_type, "tic.R")
}

use_template_tic <- function(..., target = basename(file.path(...))) {
  source <- template_file(...)
  safe_filecopy(source, target)
  message("Added ", target, " from template.")
  use_build_ignore(target)
}

use_travis_badge <- function() {
  uses_github()

  url <- glue("https://travis-ci.org/{github_repo_spec()}")
  img <- glue("{url}.svg?branch=master")

  use_badge("Travis build status", url, img)
}

#' Add test coverage via codecov or coveralls
#'
#' Enables test coverage reporting via codecov or coveralls
#'
#' @section `use_coverage()`:
#' Adds test coverage reports to a package that is already using Travis CI.
#' @name use_coverage
#' @param type Which web service to use for test reporting. Currently supports
#'   [Codecov](https://codecov.io) and [Coveralls](https://coveralls.io).
#' @export
use_coverage <- function(type = c("codecov", "coveralls")) {
  check_uses_travis()
  type <- match.arg(type)

  use_dependency("covr", "Suggests")

  switch(type,
    codecov = {
      use_template("codecov.yml", ignore = TRUE)
      use_codecov_badge()
      todo("Add to {value('.travis.yml')}:")
      code_block(
        "after_success:",
        "  - Rscript -e 'covr::codecov()'"
      )
    },

    coveralls = {
      todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
      use_coveralls_badge()
      todo("Add to {value('.travis.yml')}:")
      code_block(
        "after_success:",
        "  - Rscript -e 'covr::coveralls()'"
      )
    }
  )

  invisible(TRUE)
}

use_codecov_badge <- function() {
  check_uses_github()
  url <- glue("https://codecov.io/github/{github_repo_spec()}?branch=master")
  img <- glue(
    "https://codecov.io/gh/{github_repo_spec()}/branch/master/graph/badge.svg"
  )
  use_badge("Coverage status", url, img)
}

use_coveralls_badge <- function() {
  check_uses_github()
  url <- glue("https://coveralls.io/r/{github_repo_spec()}?branch=master")
  img <- glue(
    "https://coveralls.io/repos/github/{github_repo_spec()}/badge.svg"
  )
  use_badge("Coverage status", url, img)
}

#' Setup deployment for Travis CI
#'
#' Creates a public-private key pair,
#' adds the public key to the GitHub repository via [github_add_key()],
#' and stores the private key as an encrypted environment variable in Travis CI
#' via [travis_set_var()],
#' possibly in a different repository.
#' The \pkg{tic} companion package contains facilities for installing such a key
#' during a Travis CI build.
#'
#' @importFrom travis travis_set_var
#' @importFrom travis github_add_key
#' @importFrom tic get_public_key
#' @importFrom tic encode_private_key
#' @importFrom openssl rsa_keygen
#' @param path `[string]`\cr
#'   The path to a GitHub-enabled Git repository (or a subdirectory thereof).
#' @param info `[list]`\cr
#'   GitHub information for the repository, by default obtained through
#'   [github_info()].
#' @param repo `[string|numeric]`\cr
#'   The GitHub repo slug, by default obtained through [github_repo()].
#'   Alternatively, the Travis CI repo ID, e.g. obtained through `travis_repo_id()`.
#' @param travis_repo `[string]`\cr
#'   The Travis CI repository to add the private key to, default: `repo`
#'   (the GitHub repo to which the public deploy key is added).
#' @export
use_travis_deploy <- function(path = ".", info = travis:::github_info(path),
                              repo = travis:::github_repo(info = info)) {

  # authenticate on github and travis and set up keys/vars

  # generate deploy key pair
  key <- rsa_keygen()  # TOOD: num bits?

  # encrypt private key using tempkey and iv
  pub_key <- get_public_key(key)
  private_key <- encode_private_key(key)

  # add to GitHub first, because this can fail because of missing org permissions
  title <- glue("travis+tic for {repo}")
  github_add_key(pub_key, title = title, info = info)

  travis_set_var("id_rsa", private_key, public = FALSE, repo = repo)

  message(glue("Successfully added private deploy key to {repo}",
          " as secure environment variable id_rsa to Travis CI."))

}

use_template_tic <- function(..., target = basename(file.path(...))) {
  source <- template_file(...)
  travis:::safe_filecopy(source, target)
  message("Added ", target, " from template.")
  use_build_ignore(target)
}

template_file <- function(...) {
  system.file("templates", ..., package = utils::packageName(), mustWork = TRUE)
}

