#' Depend on another package
#'
#' `use_package()` adds a CRAN package dependency to `DESCRIPTION` and offers a
#' little advice about how to best use it. `use_dev_package()` adds a versioned
#' dependency on an in-development GitHub package, adding the repo to `Remotes`
#' so it will be automatically installed from the correct location.
#'
#' @param package Name of package to depend on.
#' @param type Type of dependency: must be one of "Imports", "Depends",
#'   "Suggests", "Enhances", or "LinkingTo" (or unique abbreviation). Matching
#'   is case insensitive.
#' @param min_version Optionally, supply a minimum version for the package.
#'   Set to `TRUE` to use the currently installed version.
#' @param remote The default is to establish a GitHub remote. Optionally,
#'   you can supply a character string to specify the remote, e.g.
#'   `"gitlab::jimhester/covr"`. See the [remotes documentation](
#'   https://remotes.r-lib.org/articles/dependencies.html#other-sources)
#'   for syntax examples.
#' @seealso The [dependencies
#'   section](https://r-pkgs.org/description.html#dependencies) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_package("ggplot2")
#' use_package("dplyr", "suggests")
#' use_dev_package("glue")
#' }
use_package <- function(package, type = "Imports", min_version = NULL) {

  if (type == "Imports") {
    refuse_package(package, verboten = "tidyverse")
  }

  use_dependency(package, type, min_version = min_version)
  how_to_use(package, type)

  invisible()
}

#' @export
#' @rdname use_package
use_dev_package <- function(package, type = "Imports", remote = NULL) {
  refuse_package(package, verboten = "tidyverse")

  use_dependency(package, type = type, min_version = TRUE)
  use_remote(package, remote)
  how_to_use(package, type)

  invisible()
}

use_remote <- function(package, remote = NULL) {
  remotes <- desc::desc_get_remotes(proj_get())
  if (any(grepl(package, remotes))) {
    return(invisible())
  }

  package_remote <- remote %||% package_remote(package)
  ui_done(
    "Adding {ui_value(package_remote)} to {ui_field('Remotes')} field in DESCRIPTION"
  )
  remotes <- c(remotes, package_remote)
  desc::desc_set_remotes(remotes, file = proj_get())
  invisible()
}

# Helpers -----------------------------------------------------------------

## TO DO: make this less hard-wired to GitHub
package_remote <- function(package) {
  desc <- desc::desc(package = package)
  # @jimhester and @gaborscardi say that the Github* fields are basically
  # legacy, e.g., to support older tools like packrat
  # Remote* fields are the way to go now
  github_info <- desc$get(c("RemoteType", "RemoteUsername", "RemoteRepo"))

  if (!identical(github_info[["RemoteType"]], "github")) {
    ui_stop("{ui_value(package)} was not installed from GitHub.")
  }

  glue::glue_data(as.list(github_info), "{RemoteUsername}/{RemoteRepo}")
}

refuse_package <- function(package, verboten) {
  if (identical(package, verboten)) {
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
  if (length(h) == 0) return()

  ui_todo("Possible includes are:")
  ui_code_block("#include <{path_file(h)}>", copy = FALSE)
}
