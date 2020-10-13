#' Use "latest" versions of all dependencies
#'
#' Pins minimum versions of dependencies to latest ones (as determined by `source`).
#' Useful for the tidyverse package, but should otherwise be used with extreme care.
#'
#' @keywords internal
#' @export
#' @param overwrite By default (`FALSE`), only dependencies without version
#'   specifications will be modified. Set to `TRUE` to modify all dependencies.
#' @param source Use "local" or "CRAN" package versions.
use_latest_dependencies <- function(overwrite = FALSE, source = c("local", "CRAN")) {
  deps <- desc::desc_get_deps(proj_get())
  deps <- update_versions(deps, overwrite = overwrite, source = source)
  desc::desc_set_deps(deps, file = proj_get())

  invisible(TRUE)
}

update_versions <- function(deps, overwrite = FALSE, source = c("local", "CRAN")) {
  baserec <- base_and_recommended()
  to_change <- !deps$package %in% c("R", baserec)
  if (!overwrite) {
    to_change <- to_change & deps$version == "*"
  }

  packages <- deps$package[to_change]
  versions <- switch(match.arg(source),
    local = map_chr(packages, ~ as.character(utils::packageVersion(.x))),
    CRAN = utils::available.packages()[packages, "Version"]
  )
  deps$version[to_change] <- paste0(">= ", versions)

  deps
}
