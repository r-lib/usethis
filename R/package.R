#' Depend on another package
#'
#' `use_package()` adds a CRAN package dependency to `DESCRIPTION` and offers a
#' little advice about how to best use it. `use_dev_package()` adds a
#' dependency on an in-development package, adding the dev repo to `Remotes` so
#' it will be automatically installed from the correct location.
#'
#' @param package Name of package to depend on.
#' @param type Type of dependency: must be one of "Imports", "Depends",
#'   "Suggests", "Enhances", or "LinkingTo" (or unique abbreviation). Matching
#'   is case insensitive.
#' @param min_version Optionally, supply a minimum version for the package.
#'   Set to `TRUE` to use the currently installed version.
#' @param remote By default, an `OWNER/REPO` GitHub remote is inserted.
#'   Optionally, you can supply a character string to specify the remote, e.g.
#'   `"gitlab::jimhester/covr"`, using any syntax supported by the [remotes
#'   package](
#'   https://remotes.r-lib.org/articles/dependencies.html#other-sources).
#'
#' @seealso The [dependencies
#'   section](https://r-pkgs.org/description.html#dependencies) of [R
#'   Packages](https://r-pkgs.org).
#'
#' @export
#' @examples
#' \dontrun{
#' use_package("ggplot2")
#' use_package("dplyr", "suggests")
#' use_dev_package("glue")
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
  remotes <- desc::desc_get_remotes(proj_get())
  if (any(grepl(package, remotes))) {
    return(invisible())
  }

  if (is.null(package_remote)) {
    desc <- desc::desc(package = package)
    package_remote <- package_remote(desc)
  }

  ui_done("
    Adding {ui_value(package_remote)} to {ui_field('Remotes')} field in \\
    DESCRIPTION")
  remotes <- c(remotes, package_remote)
  desc::desc_set_remotes(remotes, file = proj_get())
  invisible()
}

# Helpers -----------------------------------------------------------------

package_remote <- function(desc) {
  remote <- as.list(desc$get(c("RemoteType", "RemoteUsername", "RemoteRepo")))

  is_recognized_remote <- all(map_lgl(remote, ~ is_string(.x) && !is.na(.x)))

  if (is_recognized_remote) {
    # non-GitHub remotes get a 'RemoteType::' prefix
    if (!identical(remote$RemoteType, "github")) {
      remote$RemoteUsername <- paste0(remote$RemoteType, "::", remote$RemoteUsername)
    }
    return(paste0(remote$RemoteUsername, "/", remote$RemoteRepo))
  }

  package <- desc$get_field("Package")
  urls <- desc_urls(package, desc = desc)
  urls <- urls[urls$is_github, ]
  if (nrow(urls) < 1) {
    ui_stop("Cannot determine remote for {ui_value(package)}")
  }
  parsed <- parse_github_remotes(urls$url[[1]])
  remote <- paste0(parsed$repo_owner, "/", parsed$repo_name)
  if (ui_yeah("
    {ui_value(package)} was either installed from CRAN or local source.
    Based on DESCRIPTION, we propose the remote: {ui_value(remote)}
    Is this OK?")) {
    remote
  } else {
    ui_stop("Cannot determine remote for {ui_value(package)}")
  }
}

refuse_package <- function(package, verboten) {
  if (package %in% verboten) {
    code <- glue("use_package(\"{package}\", type = \"depends\")")
    ui_stop(
      "{ui_value(package)} is a meta-package and it is rarely a good idea to \\
      depend on it. Please determine the specific underlying package(s) that \\
      offer the function(s) you need and depend on that instead. \\
      For data analysis projects that use a package structure but do not implement \\
      a formal R package, adding {ui_value(package)} to Depends is a \\
      reasonable compromise. Call {ui_code(code)} to achieve this.
      "
    )
  }
  invisible(package)
}

how_to_use <- function(package, type) {
  types <- tolower(c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo"))
  type <- match.arg(tolower(type), types)

  switch(type,
    imports = ui_todo("Refer to functions with {ui_code(paste0(package, '::fun()'))}"),
    depends = ui_todo(
      "Are you sure you want {ui_field('Depends')}? \\
      {ui_field('Imports')} is almost always the better choice."
    ),
    suggests = {
      code <- glue("requireNamespace(\"{package}\", quietly = TRUE)")
      ui_todo("Use {ui_code(code)} to test if package is installed")
      code <- glue("{package}::fun()")
      ui_todo("Then directly refer to functons like {ui_code(code)} (replacing {ui_code('fun()')}).")
    },
    enhances = "",
    linkingto = show_includes(package)
  )
}

show_includes <- function(package) {
  incl <- path_package("include", package = package)
  h <- dir_ls(incl, regexp = "[.](h|hpp)$")
  if (length(h) == 0) {
    return()
  }

  ui_todo("Possible includes are:")
  ui_code_block("#include <{path_file(h)}>", copy = FALSE)
}
