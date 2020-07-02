#' Use C++ via the cpp11 package
#'
#' Adds infrastructure needed to use the [cpp11](https://cpp11.r-lib.org)
#' package, a header-only R package that helps R package developers handle R
#' objects with C++ code. compiled code:
#'   * Creates `src/`
#'   * Adds cpp11 to `DESCRIPTION`
#'   * Creates `src/code.cpp`, an initial placeholder `.cpp` file
#'
#' @export
use_cpp11 <- function() {
  check_is_package("use_cpp11()")
  check_uses_roxygen("use_cpp11()")

  use_src()

  use_dependency("cpp11", "LinkingTo")
  use_system_requirement("C++11")

  use_template(
    "code-cpp11.cpp",
    path("src", "code.cpp"),
    open = is_interactive()
  )

  invisible()
}
