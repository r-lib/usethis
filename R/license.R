#' Add licenses
#'
#' Adds the necessary infrastructure to declare your package as
#' distributed under either the MIT license (including the \code{LICENSE}
#' file), or GPL v3.
#'
#' @name licenses
#' @inheritParams use_template
#' @aliases NULL
NULL

#' @rdname licenses
#' @param copyright_holder The copyright holder for this package. Defaults to
#'   \code{getOption("devtools.name")}.
#' @export
use_mit_license <- function(copyright_holder = getOption("devtools.name", "<Author>"),
                            base_path = ".") {

  use_description_field("License", "MIT + file LICENSE", base_path = base_path)

  use_template(
    "mit-license.txt",
    "LICENSE",
    data = list(
      year = format(Sys.Date(), "%Y"),
      copyright_holder = copyright_holder
    ),
    open = identical(copyright_holder, "<Author>"),
    base_path = base_path
  )
}


#' @rdname licenses
#' @export
use_gpl3_license <- function(base_path = ".") {
  use_description_field("License", "GPL-3 + file LICENSE", base_path = base_path)
  use_template("gpl-v3.md", "LICENSE", base_path = base_path)
}
