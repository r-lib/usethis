#' Create or edit R or test files
#'
#' This pair of functions makes it easy to create paired R and test files,
#' using the convention that the tests for `R/foofy.R` should live
#' in `tests/testthat/test-foofy.R`. You can use them to create new files
#' from scratch by supplying `name`, or if you use RStudio, you can call
#' to create (or navigate to) the paired file based on the currently open
#' script.
#'
#' @section Renaming files in an existing package:
#'
#' Here are some tips on aligning file names across `R/` and `tests/testthat/`
#' in an existing package that did not necessarily follow this convention
#' before.
#'
#' This script generates a data frame of `R/` and test files that can help you
#' identify missed opportunities for pairing:
#'
#' ```
#' library(fs)
#' library(tidyverse)
#'
#' bind_rows(
#'   tibble(
#'     type = "R",
#'     path = dir_ls("R/", regexp = "\\.[Rr]$"),
#'     name = as.character(path_ext_remove(path_file(path))),
#'   ),
#'   tibble(
#'     type = "test",
#'     path = dir_ls("tests/testthat/", regexp = "/test[^/]+\\.[Rr]$"),
#'     name = as.character(path_ext_remove(str_remove(path_file(path), "^test[-_]"))),
#'   )
#' ) %>%
#'   pivot_wider(names_from = type, values_from = path) %>%
#'   print(n = Inf)
#' ```
#'
#' The [rename_files()] function can also be helpful.
#'
#' @param name Either a string giving a file name (without directory) or
#'   `NULL` to take the name from the currently open file in RStudio.
#' @inheritParams edit_file
#' @seealso The [testing](https://r-pkgs.org/tests.html) and
#'   [R code](https://r-pkgs.org/r.html) chapters of
#'   [R Packages](https://r-pkgs.org).
#' @export
use_r <- function(name = NULL, open = rlang::is_interactive()) {
  use_directory("R")

  path <- path("R", compute_name(name))
  edit_file(path, open = open)

  invisible(TRUE)
}

#' @rdname use_r
#' @export
use_test <- function(name = NULL, open = rlang::is_interactive()) {
  if (!uses_testthat()) {
    use_testthat_impl()
  }

  path <- path("tests", "testthat", paste0("test-", compute_name(name)))
  if (!file_exists(path)) {
    use_template("test-example-2.1.R", save_as = path)
  }
  edit_file(path, open = open)

  invisible(TRUE)
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

compute_name <- function(name = NULL, ext = "R", error_call = caller_env()) {
  if (!is.null(name)) {
    check_file_name(name, call = error_call)

    if (path_ext(name) == "") {
      name <- path_ext_set(name, ext)
    } else if (path_ext(name) != "R") {
      cli::cli_abort(
        "{.arg name} must have extension {.str {ext}}, not {.str {path_ext(name)}}.",
        call = error_call
      )
    }
    return(as.character(name))
  }

  if (!rstudio_available()) {
    cli::cli_abort(
      "{.arg name} is absent but must be specified.",
      call = error_call
    )
  }
  compute_active_name(
    path = rstudioapi::getSourceEditorContext()$path,
    ext = ext,
    error_call = error_call
  )
}

compute_active_name <- function(path, ext, error_call = caller_env()) {
  if (is.null(path)) {
    cli::cli_abort(
      c(
        "No file is open in RStudio.",
        i = "Please specify {.arg name}."
      ),
      call = error_call
    )
  }

  ## rstudioapi can return a path like '~/path/to/file' where '~' means
  ## R's notion of user's home directory
  path <- proj_path_prep(path_expand_r(path))

  rel_path <- path_dir(proj_rel_path(path))
  if (!rel_path %in% c("R", "src", "tests/testthat")) {
    cli::cli_abort("Open file must be a code or test file.", call = error_call)
  }

  file <- path_file(path)
  if (rel_path == "tests/testthat") {
    file <- gsub("^test[-_]", "", file)
  }
  as.character(path_ext_set(file, ext))
}

check_file_name <- function(name, call = caller_env()) {
  if (!is_string(name)) {
    cli::cli_abort("{.arg name} must be a single string", call = call)
  }

  if (name == "") {
    cli::cli_abort("{.arg name} must not be an empty string", call = call)
  }

  if (path_dir(name) != ".") {
    cli::cli_abort(
      "{.arg name} must be a file name without directory.",
      call = call
    )
  }

  if (!valid_file_name(path_ext_remove(name))) {
    cli::cli_abort(
      c(
        "{.arg name} ({.str {name}}) must be a valid file name.",
        i = "A valid file name consists of only ASCII letters, numbers, '-', and '_'."
      ),
      call = call
    )
  }
}

valid_file_name <- function(x) {
  grepl("^[a-zA-Z0-9._-]+$", x)
}

