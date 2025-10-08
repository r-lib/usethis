#' Depend on another package
#'
#' @description

#' `use_package()` adds a CRAN package dependency to `DESCRIPTION` and offers a
#' little advice about how to best use it. `use_dev_package()` adds a dependency
#' on an in-development package, adding the dev repo to `Remotes` so it will be
#' automatically installed from the correct location. There is no helper to
#' remove a dependency: to do that, simply remove that package from your
#' `DESCRIPTION` file.
#'
#' `use_package()` exists to support a couple of common maneuvers:
#' * Add a dependency to `Imports` or `Suggests` or `LinkingTo`.
#' * Add a minimum version to a dependency.
#' * Specify the minimum supported version for R.
#'
#' `use_package()` probably works for slightly more exotic modifications, but at
#' some point, you should edit `DESCRIPTION` yourself by hand. There is no
#' intention to account for all possible edge cases.
#'
#' @param package Name of package to depend on.
#' @param type Type of dependency: must be one of "Imports", "Depends",
#'   "Suggests", "Enhances", or "LinkingTo" (or unique abbreviation). Matching
#'   is case insensitive.
#' @param min_version Optionally, supply a minimum version for the package. Set
#'   to `TRUE` to use the currently installed version or use a version string
#'   suitable for [numeric_version()], such as "2.5.0".
#' @param remote By default, an `OWNER/REPO` GitHub remote is inserted.
#'   Optionally, you can supply a character string to specify the remote, e.g.
#'   `"gitlab::jimhester/covr"`, using any syntax supported by the [remotes
#'   package](
#'   https://remotes.r-lib.org/articles/dependencies.html#other-sources).
#'
#' @seealso The [dependencies section](https://r-pkgs.org/dependencies-mindset-background.html) of
#'   [R Packages](https://r-pkgs.org).
#'
#' @export
#' @examples
#' \dontrun{
#' use_package("ggplot2")
#' use_package("dplyr", "suggests")
#' use_dev_package("glue")
#'
#' # Depend on R version 4.1
#' use_package("R", type = "Depends", min_version = "4.1")
#' }
use_package <- function(package, type = "Imports", min_version = NULL) {
  if (type == "Imports") {
    refuse_package(package, verboten = c("tidyverse", "tidymodels"))
  }

  changed <- use_dependency(package, type, min_version = min_version)
  if (changed) {
    how_to_use(package, type)
  }

  invisible()
}

#' @export
#' @rdname use_package
use_dev_package <- function(package, type = "Imports", remote = NULL) {
  refuse_package(package, verboten = c("tidyverse", "tidymodels"))

  changed <- use_dependency(package, type = type, min_version = TRUE)
  use_remote(package, remote)
  if (changed) {
    how_to_use(package, type)
  }

  invisible()
}

use_remote <- function(package, package_remote = NULL) {
  desc <- proj_desc()

  remotes <- desc$get_remotes()
  if (any(grepl(package, remotes))) {
    return(invisible())
  }

  if (is.null(package_remote)) {
    package_desc <- desc::desc(package = package)
    package_remote <- package_remote(package_desc)
  }

  ui_bullets(c(
    "v" = "Adding {.val {package_remote}} to {.field Remotes} field in
           DESCRIPTION."
  ))
  remotes <- c(remotes, package_remote)

  desc$set_remotes(remotes)
  desc$write()

  invisible()
}

# Helpers -----------------------------------------------------------------

package_remote <- function(desc) {
  remote <- as.list(desc$get(c("RemoteType", "RemoteUsername", "RemoteRepo")))

  is_recognized_remote <- all(map_lgl(remote, \(x) is_string(x) && !is.na(x)))

  if (is_recognized_remote) {
    # non-GitHub remotes get a 'RemoteType::' prefix
    if (!identical(remote$RemoteType, "github")) {
      remote$RemoteUsername <- paste0(
        remote$RemoteType,
        "::",
        remote$RemoteUsername
      )
    }
    return(paste0(remote$RemoteUsername, "/", remote$RemoteRepo))
  }

  package <- desc$get_field("Package")
  urls <- desc_urls(package, desc = desc)
  urls <- urls[urls$is_github, ]
  if (nrow(urls) < 1) {
    ui_abort("Cannot determine remote for {.pkg {package}}.")
  }
  parsed <- parse_github_remotes(urls$url[[1]])
  remote <- paste0(parsed$repo_owner, "/", parsed$repo_name)
  if (
    ui_yep(c(
      "!" = "{.pkg {package}} was either installed from CRAN or local source.",
      "i" = "Based on DESCRIPTION, we propose the remote: {.val {remote}}.",
      " " = "Is this OK?"
    ))
  ) {
    remote
  } else {
    ui_abort("Cannot determine remote for {.pkg {package}}.")
  }
}

refuse_package <- function(package, verboten) {
  if (package %in% verboten) {
    code <- glue('use_package("{package}", type = "depends")')
    ui_abort(c(
      "x" = "{.pkg {package}} is a meta-package and it is rarely a good idea to
             depend on it.",
      "_" = "Please determine the specific underlying package(s) that provide
             the function(s) you need and depend on that instead.",
      "i" = "For data analysis projects that use a package structure but do not
             implement a formal R package, adding {.pkg {package}} to
             {.field Depends} is a reasonable compromise.",
      "_" = "Call {.code {code}} to achieve this."
    ))
  }
  invisible(package)
}

how_to_use <- function(package, type) {
  types <- tolower(c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo"))
  type <- match.arg(tolower(type), types)
  if (package == "R" && type == "depends") {
    return("")
  }

  switch(
    type,
    imports = ui_bullets(c(
      "_" = "Refer to functions with {.code {paste0(package, '::fun()')}}."
    )),
    depends = ui_bullets(c(
      "!" = "Are you sure you want {.field Depends}?
             {.field Imports} is almost always the better choice."
    )),
    suggests = suggests_usage_hint(package),
    enhances = "",
    linkingto = show_includes(package)
  )
}

suggests_usage_hint <- function(package) {
  imports_rlang <- proj_desc()$has_dep("rlang", type = "Imports")
  if (imports_rlang) {
    code1 <- glue('rlang::is_installed("{package}")')
    code2 <- glue('rlang::check_installed("{package}")')
    ui_bullets(c(
      "_" = "In your package code, use {.code {code1}} or {.code {code2}} to
             test if {.pkg {package}} is installed."
    ))
    code <- glue("{package}::fun()")
    ui_bullets(c("_" = "Then directly refer to functions with {.code {code}}."))
  } else {
    code <- glue('requireNamespace("{package}", quietly = TRUE)')
    ui_bullets(c(
      "_" = "Use {.code {code}} to test if {.pkg {package}} is installed."
    ))
    code <- glue("{package}::fun()")
    ui_bullets(c("_" = "Then directly refer to functions with {.code {code}}."))
  }
}

show_includes <- function(package) {
  incl <- path_package("include", package = package)
  h <- dir_ls(incl, regexp = "[.](h|hpp)$")
  if (length(h) == 0) {
    return()
  }

  ui_bullets(c("Possible includes are:"))
  ui_code_snippet("#include <{path_file(h)}>", copy = FALSE, language = "")
}
