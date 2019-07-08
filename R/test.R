#' Sets up overall testing infrastructure
#' creates
#'   `tests/testthat/`, `tests/testthat.R`, and adds testthat to Suggests.
#'
#' @seealso [use_test] to create test files. The [testing chapter](https://r-pkgs.org/tests.html) of [R
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

#' @rdname creating-files
#' @param open
#' * If TRUE, opens the file for editing. Defaults to return value of `interactive()`.
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
