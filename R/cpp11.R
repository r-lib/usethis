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

  check_cpp_register_deps()

  invisible()
}

get_cpp_register_deps <- function() {
  res <- desc::desc(package = "cpp11")$get_field("Config/Needs/cpp11/cpp_register")
  strsplit(res, "[[:space:]]*,[[:space:]]*")[[1]]
}

check_cpp_register_deps <- function() {
  cpp_register_deps <- get_cpp_register_deps()
  installed <- map_lgl(cpp_register_deps, is_installed)

  if (!all(installed)) {
    ui_todo("Now install {ui_value(cpp_register_deps[!installed])} to use cpp11.")
  }
}
