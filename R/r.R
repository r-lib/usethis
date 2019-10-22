#' Create or edit R or test files
#'
#' This pair of functions makes it easy to create paired R and test files,
#' using the convention that the tests for `R/foofy.R` should live
#' in `tests/testhat/test-foofy.R`. You can use them to create new files
#' from scratch by supplying `name`, or if you use RStudio, you can call
#' to create (or navigate to) the paired file based on the currently open
#' script.
#'
#' @param name Either a name without extension, or `NULL` to create the
#'   paired file based on currently open file in the script editor. If
#'   the R file is open, `use_test()` will create/open the corresponding
#'   test file; if the test file is open, `use_r()` will create/open the
#'   corresponding R file.
#' @inheritParams edit_file
#' @seealso The [testing](https://r-pkgs.org/tests.html) and
#'   [R code](https://r-pkgs.org/r.html) chapters of
#'   [R Packages](https://r-pkgs.org).
#' @export
use_r <- function(name = NULL, open = NULL) {
  name <- name %||% get_active_r_file(path = "tests/testthat")
  name <- gsub("^test-", "", name)
  name <- slug(name, "R")
  check_file_name(name)

  use_directory("R")
  edit_file(proj_path("R", name), open = open)

  invisible(TRUE)
}

#' @rdname use_r
#' @export
use_test <- function(name = NULL, open = NULL) {
  if (!uses_testthat()) {
    use_testthat()
  }

  name <- name %||% get_active_r_file(path = "R")
  name <- paste0("test-", name)
  name <- slug(name, "R")
  check_file_name(name)

  path <- path("tests", "testthat", name)
  if (!file_exists(path)) {
    # As of testthat 2.1.0, a context() is no longer needed/wanted
    if (utils::packageVersion("testthat") >= "2.1.0") {
      use_dependency("testthat", "Suggests", "2.1.0")
      use_template(
        "test-example-2.1.R",
        save_as = path,
        open = FALSE
      )
    } else {
      use_template(
        "test-example.R",
        save_as = path,
        data = list(test_name = path_ext_remove(name)),
        open = FALSE
      )
    }
  }

  edit_file(proj_path(path), open = open)

}


# helpers -----------------------------------------------------------------

check_file_name <- function(name) {
  if (!is_string(name)) {
    ui_stop("Name must be a single string")
  }
  if (!valid_file_name(path_ext_remove(name))) {
    ui_stop(c(
      "{ui_value(name)} is not a valid file name. It should:",
      "* Contain only ASCII letters, numbers, '-', and '_'."
    ))
  }
  name
}

valid_file_name <- function(x) {
  grepl("^[a-zA-Z0-9._-]+$", x)
}

get_active_r_file <- function(path = "R") {
  if (!rstudioapi::isAvailable()) {
    ui_stop("Argument {ui_code('name')} must be specified.")
  }
  active_file <- rstudioapi::getSourceEditorContext()$path
  ## rstudioapi can return a path like '~/path/to/file' where '~' means
  ## R's notion of user's home directory
  active_file <- proj_path_prep(path_expand_r(active_file))

  rel_path <- proj_rel_path(active_file)
  if (path_dir(rel_path) != path) {
    ui_stop(c(
      "Open file must be in the {ui_path(path)} directory of the active package.",
      "  * Actual path: {ui_path(rel_path)}"
    ))
  }

  ext <- path_ext(active_file)
  if (toupper(ext) != "R") {
    ui_stop(
      "Open file must have {ui_value('.R')} or {ui_value('.r')} as extension,\\
      not {ui_value(ext)}."
    )
  }

  path_file(active_file)
}
