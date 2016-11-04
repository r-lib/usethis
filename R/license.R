#' @rdname infrastructure
#' @section \code{use_mit_license}:
#' Adds the necessary infrastructure to declare your package as
#' distributed under the MIT license.
#' @param copyright_holder The copyright holder for this package. Defaults to
#'   \code{getOption("devtools.name")}.
#' @export
use_mit_license <- function(pkg = ".", copyright_holder = getOption("devtools.name", "<Author>")) {
  pkg <- as.package(pkg)

  # Update the DESCRIPTION
  message("* Updating license field in DESCRIPTION.")
  descPath <- file.path(pkg$path, "DESCRIPTION")
  DESCRIPTION <- read_dcf(descPath)
  DESCRIPTION$License <- "MIT + file LICENSE"
  write_dcf(descPath, DESCRIPTION)

  use_template(
    "mit-license.txt",
    "LICENSE",
    data = list(
      year = format(Sys.Date(), "%Y"),
      copyright_holder = copyright_holder
    ),
    open = identical(copyright_holder, "<Author>"),
    pkg = pkg
  )
}


#' @rdname infrastructure
#' @section \code{use_gpl3_license}:
#' Adds the necessary infrastructure to declare your package as
#' distributed under the GPL v3.
#' @export
use_gpl3_license <- function(pkg = ".") {
  pkg <- as.package(pkg)

  # Update the DESCRIPTION
  message("* Updating license field in DESCRIPTION.")
  descPath <- file.path(pkg$path, "DESCRIPTION")
  DESCRIPTION <- read_dcf(descPath)
  DESCRIPTION$License <- "GPL-3 + file LICENSE"
  write_dcf(descPath, DESCRIPTION)

  use_template("gpl-v3.md", "LICENSE", pkg = pkg)
}
