#' Add a code of conduct
#'
#' The goal of a code of conduct is to foster an environment of inclusiveness,
#' and to explicit discourage inappropriate behaviour. This code of conduct
#' comes from \url{http://contributor-covenant.org}, version 1:
#' \url{http://contributor-covenant.org/version/1/0/0/}.
#'
#' @export
#' @inheritParams use_template
use_code_of_conduct <- function(base_path = ".") {
  use_template(
    "CONDUCT.md",
    ignore = TRUE,
    base_path = base_path
  )

  message("* Don't forget to describe the code of conduct in your README.md:")
  message(
    "Please note that this project is released with a ",
    "[Contributor Code of Conduct](CONDUCT.md). \n",
    "By participating in this project you agree to abide by its terms."
  )
}
