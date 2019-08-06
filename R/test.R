#' Create tests
#'
#' There are two helper functions:
#' * `use_testthat()` sets up overall testing infrastructure: creates
#'   `tests/testthat/`, `tests/testthat.R`, and adds testthat to Suggests.
#' * `use_test()` sets up individual test files: creates
#'   `tests/testthat/test-<name>.R` and, optionally, opens it for editing.
#'
#' @seealso The [testing chapter](https://r-pkgs.org/tests.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @inheritParams use_template
#' @examples
#' \dontrun{
#' use_testthat()
#'
#' use_test()
#'
#' use_test("something-management")
#' }
use_testthat <- function() {
  check_is_package("use_testthat()")
  check_installed("testthat")

  use_dependency("testthat", "Suggests")
  use_directory(path("tests", "testthat"))
  use_template(
    "testthat.R",
    save_as = path("tests", "testthat.R"),
    data = list(name = project_name())
  )
  ui_todo(
    "Call {ui_code('use_test()')} to initialize a basic test file and open it \\
    for editing."
  )
}

#' @rdname use_testthat
#' @param name Base of test file name. If `NULL`, and you're using RStudio, will
#'   be based on the name of the file open in the source editor.
#' @export
use_test <- function(name = NULL, open = interactive()) {
  if (!uses_testthat()) {
    use_testthat()
  }

  if (is.null(name)) {
    name <- get_active_r_file(path = "R")
  } else {
    check_file_name(name)
  }

  name <- paste0("test-", name)
  name <- slug(name, "R")
  path <- path("tests", "testthat", name)

  if (file_exists(proj_path(path))) {
    if (open) {
      edit_file(proj_path(path))
    }
    return(invisible(TRUE))
  }

  # As of testthat 2.1.0, a context() is no longer needed/wanted
  if (utils::packageVersion("testthat") >= "2.1.0") {
    use_dependency("testthat", "Suggests", "2.1.0")
    use_template(
      "test-example-2.1.R",
      save_as = path,
      open = open
    )
  } else {
    use_template(
      "test-example.R",
      save_as = path,
      data = list(test_name = path_ext_remove(name)),
      open = open
    )
  }
}

uses_testthat <- function(base_path = proj_get()) {
  paths <- c(
    path(base_path, "inst", "tests"),
    path(base_path, "tests", "testthat")
  )

  any(dir_exists(paths))
}
