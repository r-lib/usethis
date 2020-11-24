#' Create or edit R or test files
#'
#' This pair of functions makes it easy to create paired R and test files,
#' using the convention that the tests for `R/foofy.R` should live
#' in `tests/testthat/test-foofy.R`. You can use them to create new files
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
use_r <- function(name = NULL, open = rlang::is_interactive()) {
  name <- name %||% get_active_r_file(path = "tests/testthat")
  name <- gsub("^test-", "", name)
  name <- slug(name, "R")
  check_file_name(name)

  use_directory("R")
  edit_file(proj_path("R", name), open = open)

  test_path <- proj_path("tests", "testthat", paste0("test-", name, ".R"))
  if (!file_exists(test_path)) {
    ui_todo("Call {ui_code('use_test()')} to create a matching test file")
  }

  invisible(TRUE)
}

#' @rdname use_r
#' @export
use_test <- function(name = NULL, open = rlang::is_interactive()) {
  if (!uses_testthat()) {
    use_testthat_impl()
  }

  name <- name %||% get_active_r_file(path = "R")
  name <- paste0("test-", name)
  name <- slug(name, "R")
  check_file_name(name)

  path <- path("tests", "testthat", name)
  if (!file_exists(path)) {
    use_template("test-example-2.1.R", save_as = path, open = FALSE)
  }

  edit_file(proj_path(path), open = open)
}

#' Automatically rename paired `R/` and `test/` files
#'
#' @description
#' * Moves `R/{old}.R` to `R/{new}.R`
#' * Moves `tests/testthat/test-{old}.R` to `tests/testthat/test-{new}.R`
#' * Moves `tests/testthat/test-{old}-*.*` to `tests/testthat/test-{new}-*.*`
#'   and updates paths in the test file.
#' * Removes `context()` calls from the test file, which are unnecessary
#'   (and discouraged) as of testthat v2.1.0.
#'
#' This is a potentially dangerous operation, so you must be using Git in
#' order to use this function.
#'
#' @param old,new Old and new file names (with or without extensions).
#' @export
rename_files <- function(old, new) {
  check_uses_git()

  old <- path_ext_remove(old)
  new <- path_ext_remove(new)

  # Move .R file
  r_old_path <- proj_path("R", old, ext = "R")
  r_new_path <- proj_path("R", new, ext = "R")
  if (file_exists(r_old_path)) {
    ui_done("Moving {ui_path(r_old_path)} to {ui_path(r_new_path)}")
    file_move(r_old_path, r_new_path)
  }

  if (!uses_testthat()) {
    return(invisible())
  }

  # Move test files and snapshots
  rename_test <- function(path) {
    file <- gsub(glue("^test-{old}"), glue("test-{new}"), path_file(path))
    file <- gsub(glue("^{old}.md"), glue("{new}.md"), file)
    path(path_dir(path), file)
  }
  old_test <- dir_ls(
    proj_path("tests", "testthat"),
    glob = glue("*/test-{old}*")
  )
  new_test <- rename_test(old_test)
  if (length(old_test) > 0) {
    ui_done("Moving {ui_path(old_test)} to {ui_path(new_test)}")
    file_move(old_test, new_test)
  }
  snaps_dir <- proj_path("tests", "testthat", "_snaps")
  if (dir_exists(snaps_dir)) {
    old_snaps <- dir_ls(snaps_dir, glob = glue("*/{old}.md"))
    if (length(old_snaps) > 0) {
      new_snaps <- rename_test(old_snaps)
      ui_done("Moving {ui_path(old_snaps)} to {ui_path(new_snaps)}")
      file_move(old_snaps, new_snaps)
    }
  }

  # Update test file
  test_path <- proj_path("tests", "testthat", glue("test-{new}"), ext = "R")
  if (!file_exists(test_path)) {
    return(invisible())
  }

  lines <- read_utf8(test_path)

  # Remove old context lines
  context <- grepl("context\\(.*\\)", lines)
  if (any(context)) {
    ui_done("Removing call to {ui_code('context()')}")
    lines <- lines[!context]
    if (lines[[1]] == "") {
      lines <- lines[-1]
    }
  }

  old_test <- old_test[new_test != test_path]
  new_test <- new_test[new_test != test_path]

  if (length(old_test) > 0) {
    ui_done("Updating paths in {ui_path(test_path)}")

    for (i in seq_along(old_test)) {
      lines <- gsub(path_file(old_test[[i]]), path_file(new_test[[i]]), lines, fixed = TRUE)
    }
  }

  write_utf8(test_path, lines)
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
  if (!rstudio_available()) {
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
