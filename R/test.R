#' Create tests
#'
#' `use_testthat` sets up testing infrastructure, creating
#' \file{tests/testthat.R} and \file{tests/testthat/}, and
#' adding \pkg{testthat} to the suggested packages. `use_test`
#' creates \file{tests/testthat/test-<name>.R} and opens it for editing.
#'
#' @export
#' @inheritParams use_template
use_testthat <- function() {
  check_installed("testthat")

  use_dependency("testthat", "Suggests")
  use_directory("tests/testthat")
  use_template(
    "testthat.R",
    "tests/testthat.R",
    data = list(name = project_name())
  )

  invisible(TRUE)
}

#' @rdname use_testthat
#' @param name Test name. if `NULL`, and you're using RStudio, will use
#'   the name of the file open in the source editor.
#' @export
use_test <- function(name = NULL, open = TRUE) {
  name <- find_test_name(name)

  if (!uses_testthat()) {
    use_testthat()
  }

  path <- file.path("tests", "testthat", name)

  if (file.exists(file.path(proj_get(), path))) {
    edit_file(proj_get(), path)
  } else {
    use_template("test-example.R",
      path,
      data = list(test_name = name),
      open = open
    )
  }


  invisible(TRUE)
}

uses_testthat <- function(base_path = proj_get()) {
  paths <- c(
    file.path(base_path, "inst", "tests"),
    file.path(base_path, "tests", "testthat")
  )

  any(dir.exists(paths))
}

find_test_name <- function(name = NULL) {
  if (!is.null(name)) {
    return(paste0("test-", slug(name, ".R")))
  }

  if (!rstudioapi::isAvailable()) {
    stop("Argument `name` is missing, with no default", call. = FALSE)
  }
  active_file <- rstudioapi::getSourceEditorContext()$path

  dir <- basename(dirname(active_file))
  if (dir != "R") {
    stop("Open file not in `R/` directory", call. = FALSE)
  }

  if (!grepl("\\.[Rr]$", active_file)) {
    stop("Open file is does not end in `.R`", call. = FALSE)
  }

  paste0("test-", basename(active_file))
}
