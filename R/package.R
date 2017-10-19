#' Use specified package.
#'
#' `use_package()` adds a CRAN package dependency to DESCRIPTION and offers a
#' little advice about how to best use it. `use_dev_package()` adds a
#' dependency on an in-development GitHub package, adding the repo to
#' `Remotes` so it will be automatically installed from the correct location.
#'
#' @param package Name of package to depend on.
#' @param type Type of dependency: must be one of "Imports", "Suggests",
#'   "Depends", "Suggests", "Enhances", or "LinkingTo" (or unique abbreviation)
#' @inheritParams use_template
#' @export
#' @examples
#' \dontrun{
#' use_package("ggplot2")
#' use_package("dplyr", "suggests")
#' }
use_package <- function(package, type = "Imports") {
  use_dependency(package, type)

  switch(tolower(type),
    imports = todo("Refer to functions with ", code(package, "::fun()")),
    depends = todo("Are you sure you want Depends? Imports is almost always the better choice."),
    suggests = {
      todo(
        "Use ", code("requireNamespace(\"", package, "\", quietly = TRUE)"),
        " to test if package is installed"
      )
      todo("Then use ", code(package, "::fun()"), " to refer to functions.")
    },
    enhances = "",
    linkingTo = show_includes(package)
  )

  invisible()
}

show_includes <- function(package) {
  incl <- system.file("include", package = package)
  h <- dir(incl, "\\.(h|hpp)$")
  if (length(h) == 0) return()

  todo("Possible includes are:")
  code_block(paste0("#include <", h, ">"))
}

#' @export
#' @rdname use_package
use_dev_package <- function(package, type = "Imports") {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(package, " must be installed before you can take a dependency on it",
      call. = FALSE)
  }

  use_package(package, type = type)

  package_remote <- package_remote(package)
  remotes <- desc::desc_get_remotes(proj_get())
  if (package_remote %in% remotes) {
    return(invisible())
  }

  done("Adding ", value(package_remote), " to DESCRIPTION ", field("Remotes"))
  remotes <- c(remotes, package_remote)
  desc::desc_set_remotes(remotes, file = proj_get())

  invisible()
}

package_remote <- function(package) {
  desc <- desc::desc(package = package)
  github_info <- desc$get(c("GithubUsername", "GithubRepo"))

  if (any(is.na(github_info))) {
    stop(package, " was not installed from GitHub", call. = FALSE)
  }

  paste0(github_info, collapse = "/")
}
