#' Create tests
#'
#' `use_testthat()` sets up testing infrastructure, creating `tests/testthat.R`
#' and `tests/testthat/`, and adding testthat as a Suggested package.
#' `use_test()` creates `tests/testthat/test-<name>.R` and opens it for editing.
#'
#' @seealso The [testing chapter](https://r-pkgs.org/tests.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @inheritParams use_template
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
}

#' @rdname use_testthat
#' @param name Base of test file name. If `NULL`, and you're using RStudio, will
#'   be based on the name of the file open in the source editor.
#' @export
use_test <- function(name = NULL, open = interactive()) {
  if (!uses_testthat()) {
    use_testthat()
  }

  name <- name %||% get_active_r_file(path = "R")
  check_file_name(name)
  # REMOVE THIS PRIOR TO MERGE: #581
  # if (is.null(name)) {
  #   name <- get_active_r_file(path = "R")
  #   if (!valid_file_name(fs::path_ext_remove(name))) {
  #     warning(
  #       stringr::str_glue(
  #         "Active file contains non-ASCII characters.
  #         Consider renaming file using only ASCII letters, numbers,
  #         '-', and '_'."
  #       ),
  #       call. = FALSE)
  #   }
  # } else {
  # }
  # RM ABOVE -> issue #581
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
