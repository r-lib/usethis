#' Add a code of conduct
#'
#' Adds a `CODE_OF_CONDUCT.md` file to the project's top-level directory. The
#' goal of a code of conduct is to foster an environment of inclusiveness, and
#' to explicitly discourage inappropriate behaviour. The template comes from
#' <http://contributor-covenant.org>, version 1:
#' <http://contributor-covenant.org/version/1/0/0/>.
#'
#' @export
use_code_of_conduct <- function() {
  use_template(
    "CODE_OF_CONDUCT.md",
    ignore = TRUE
  )

  todo("Don't forget to describe the code of conduct in your README.md:")
  code_block(
    "Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).",
    "By participating in this project you agree to abide by its terms."
  )
}
