#' Use C++ via the cpp11 package
#'
#' Adds infrastructure needed to use the [cpp11](https://cpp11.r-lib.org)
#' package, a header-only R package that helps R package developers handle R
#' objects with C++ code:
#'   * Creates `src/`
#'   * Adds cpp11 to `DESCRIPTION`
#'   * Creates `src/code.cpp`, an initial placeholder `.cpp` file
#'
#' @export
use_cpp11 <- function() {
  check_installed("cpp11")
  check_is_package("use_cpp11()")
  check_uses_roxygen("use_cpp11()")
  use_src()

  use_dependency("cpp11", "LinkingTo")

  use_template(
    "code-cpp11.cpp",
    path("src", "code.cpp"),
    open = is_interactive()
  )

  check_cpp_register_deps()

  check_cpp_dynlib()

  invisible()
}

get_cpp_register_deps <- function() {
  desc <- desc::desc(package = "cpp11")
  desc$get_list("Config/Needs/cpp11/cpp_register")[[1]]
}

check_cpp_register_deps <- function() {
  cpp_register_deps <- get_cpp_register_deps()
  installed <- map_lgl(cpp_register_deps, is_installed)

  if (!all(installed)) {
    ui_todo("Now install {ui_value(cpp_register_deps[!installed])} to use cpp11.")
  }
}

get_cpp_dynlib <- function() {
  desc <- desc::desc(package = NULL)
  desc$get_list("Package")[[1]]
}

check_cpp_dynlib <- function() {
  pkgname <- get_cpp_dynlib()
  use_template(
    "code-cpp11-dynlib.R",
    data = list(Package = pkgname),
    save_as = path("R", paste0(pkgname, "-package.R")),
    open = is_interactive()
  )
}
