#' Create or edit files
#'
#' There are two functions for creating files:
#' * `use_r()` creates `<name>.R` file in the `R` directory.
#' * `use_test()` sets up individual test files: creates `tests/testthat/test-<name>.R` and, optionally, opens it for editing.
#' @name creating-files
#' @param name
#' * for `use_r()`: File name, without extension; will create if it doesn't already
#'   exist. If not specified, and you're currently in a test file, will guess
#'   name based on test name.
#' * for `use_test()`: Base of test file name. If `NULL`, and you're using RStudio, will
#'   be based on the name of the file open in the source editor.
NULL
