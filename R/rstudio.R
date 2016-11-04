#' @export
#' @rdname infrastructure
use_rstudio <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_template(
    "template.Rproj",
    paste0(pkg$package, ".Rproj"),
    pkg = pkg
  )

  use_git_ignore(c(".Rproj.user", ".Rhistory", ".RData"), pkg = pkg)
  use_build_ignore(c("^.*\\.Rproj$", "^\\.Rproj\\.user$"), escape = FALSE, pkg = pkg)

  invisible(TRUE)
}

open_in_rstudio <- function(path, base_path = ".") {
  path <- file.path(base_path, path)

  if (!rstudioapi::isAvailable())
    return()

  if (!rstudioapi::hasFun("navigateToFile"))
    return()

  rstudioapi::navigateToFile(path)
}

