#' @rdname infrastructure
#' @section \code{use_code_of_conduct}:
#' Add a code of conduct to from \url{http://contributor-covenant.org}.
#'
#' @export
#' @aliases add_travis
use_code_of_conduct <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_template(
    "CONDUCT.md",
    ignore = TRUE,
    pkg = pkg
  )

  message("* Don't forget to describe the code of conduct in your README.md:")
  message("Please note that this project is released with a ",
    "[Contributor Code of Conduct](CONDUCT.md). ", "By participating in this ",
    "project you agree to abide by its terms.")
}
