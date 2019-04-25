#' Tidy eval helpers
#'
#' @description
#'
#' * \code{\link[rlang:quotation]{sym}()} creates a symbol from a string and
#'   \code{\link[rlang:quotation]{syms}()} creates a list of symbols from a
#'   character vector.
#'
#' * \code{\link[rlang:quotation]{expr}()} and \code{\link[rlang:quotation]{quo}()} quote
#'   one expression. `quo()` wraps the quoted expression in a quosure.
#'
#'   The plural variants \code{\link[rlang:quotation]{exprs()}} and
#'   \code{\link[rlang:quotation]{quos}()} return a list of quoted expressions or
#'   quosures.
#'
#' * \code{\link[rlang:quotation]{enexpr}()} and \code{\link[rlang:quotation]{enquo}()}
#'   capture the expression supplied as argument by the user of the
#'   current function (`enquo()` wraps this expression in a quosure).
#'
#'   \code{\link[rlang:quotation]{enexprs}()} and \code{\link[rlang:quotation]{enquos}()}
#'   capture multiple expressions supplied as arguments, including
#'   `...`.
#'
#' `exprs()` is not exported to avoid conflicts with `Biobase::exprs()`,
#' therefore one should always use `rlang::exprs()`.
#'
#' To learn more about tidy eval and how to use these tools, visit
#' <http://rlang.r-lib.org> and the [Metaprogramming
#' section](https://adv-r.hadley.nz/metaprogramming.html) of [Advanced
#' R](https://adv-r.hadley.nz).
#'
#' @md
#' @name     tidyeval
#' @keywords internal
#' @importFrom rlang quo quos enquo enquos quo_name sym ensym syms
#'                   ensyms expr exprs enexpr enexprs .data :=
#' @aliases  quo quos enquo enquos quo_name
#'           sym ensym syms ensyms
#'           expr exprs enexpr enexprs
#'           .data :=
#' @export   quo quos enquo enquos quo_name
#' @export   sym ensym syms ensyms
#' @export   expr enexpr enexprs
#' @export   .data :=
NULL
