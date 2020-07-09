#' Sets up overall testing infrastructure
#'
#' Creates `tests/testthat/`, `tests/testthat.R`, and adds the testthat package
#' to the Suggests field. Learn more in <https://r-pkgs.org/tests.html>
#'
#' @seealso [use_test()] to create individual test files
#' @export
#' @examples
#' \dontrun{
#' use_testthat()
#'
#' use_test()
#'
#' use_test("something-management")
#' }
use_testthat <- function() {
  use_testthat_impl()

  ui_todo(
    "Call {ui_code('use_test()')} to initialize a basic test file and open it \\
    for editing."
  )
}

use_testthat_impl <- function() {
  check_installed("testthat")
  if (utils::packageVersion("testthat") < "2.1.0") {
    ui_stop("testthat 2.1.0 or greater needed. Please install before re-trying")
  }

  if (is_package()) {
    use_dependency("testthat", "Suggests")
  }

  use_directory(path("tests", "testthat"))
  use_template(
    "testthat.R",
    save_as = path("tests", "testthat.R"),
    data = list(name = project_name())
  )
}


uses_testthat <- function(base_path = proj_get()) {
  paths <- c(
    path(base_path, "inst", "tests"),
    path(base_path, "tests", "testthat")
  )

  any(dir_exists(paths))
}
