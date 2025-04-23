#' Use "latest" versions of all dependencies
#'
#' Pins minimum versions of all `Imports` and `Depends` dependencies to latest
#' ones (as determined by `source`). Useful for the tidyverse package, but
#' should otherwise be used with extreme care.
#'
#' @keywords internal
#' @export
#' @param overwrite By default (`TRUE`), all dependencies will be modified.
#'   Set to `FALSE` to only modify dependencies without version
#'   specifications.
#' @param source Use "CRAN" or "local" package versions.
use_latest_dependencies <- function(
  overwrite = TRUE,
  source = c("CRAN", "local")
) {
  source <- arg_match(source)

  desc <- proj_desc()
  updated <- update_versions(
    desc$get_deps(),
    overwrite = overwrite,
    source = source
  )

  desc$set_deps(updated)
  desc$write()

  invisible(TRUE)
}

update_versions <- function(
  deps,
  overwrite = TRUE,
  source = c("CRAN", "local")
) {
  baserec <- base_and_recommended()
  to_change <- !deps$package %in% c("R", baserec) & deps$type != "Suggests"
  if (!overwrite) {
    to_change <- to_change & deps$version == "*"
  }

  packages <- deps$package[to_change]
  versions <- switch(
    match.arg(source),
    local = map_chr(packages, \(x) as.character(utils::packageVersion(x))),
    CRAN = utils::available.packages()[packages, "Version"]
  )
  deps$version[to_change] <- paste0(">= ", versions)

  deps
}
