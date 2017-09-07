#' Tidy eval helpers
#'
#' These six functions provide tidy eval-compatible ways to capture
#' symbols (`sym()`, `syms()`, `ensym()`), expressions (`expr()`,
#' `exprs()`, `enexpr()`), and quosures (`quo()`, `quos()`, `enquo()`).
#' To learn more about tidy eval and how to use these tools, read
#' <http://rlang.tidyverse.org/articles/tidy-evaluation.html>
#'
#' @md
#' @name tidyeval
#' @keywords internal
#' @aliases          quo quos enquo sym syms ensym expr exprs enexpr
#' @importFrom rlang quo quos enquo
#' @export           quo quos enquo
#' @importFrom rlang sym syms ensym
#' @export           sym syms ensym
#' @importFrom rlang expr exprs enexpr
#' @export           expr exprs enexpr
NULL

# Flag inline helpers as global variables so R CMD check doesn't warn
utils::globalVariables(c(":=", ".data", ".env"))

