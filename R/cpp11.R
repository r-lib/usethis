#' Use C++ via the cpp11 package
#'
#' Adds infrastructure commonly needed when using compiled code:
#'   * Creates `src/`
#'   * Adds required packages to `DESCRIPTION`
#'   * May create an initial placeholder `.c` or `.cpp` file
#'
#' @param name If supplied, creates and opens `src/name.{c,cpp}`.
#'
#' @details
#'
#' When using compiled code, please note that there must be at least one file
#' inside the `src/` directory prior to building the package. As a result,
#' if an empty `src/` directory is detected, either a `.c` or `.cpp` file will
#' be added.
#'
#' @export
use_cpp11 <- function(name = NULL) {
  check_is_package("use_cpp11()")
  check_uses_roxygen("use_cpp11()")

  use_src()

  use_dependency("cpp11", "LinkingTo")

  use_template(
    "code-cpp11.cpp",
    path("src", "code.cpp"),
    open = is_interactive()
  )

  invisible()
}
