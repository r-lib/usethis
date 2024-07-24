#' Create or edit R or test files
#'
#' This pair of functions makes it easy to create paired R and test files,
#' using the convention that the tests for `R/foofy.R` should live
#' in `tests/testthat/test-foofy.R`. You can use them to create new files
#' from scratch by supplying `name`, or if you use RStudio, you can call
#' to create (or navigate to) the companion file based on the currently open
#' file. This also works when a test snapshot file is active, i.e. if you're
#' looking at `tests/testthat/_snaps/foofy.md`, `use_r()` or `use_test()` take
#' you to `R/foofy.R` or `tests/testthat/test-foofy.R`, respectively.
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
#' @seealso
#' * The [testing](https://r-pkgs.org/testing-basics.html) and
#'   [R code](https://r-pkgs.org/code.html) chapters of
#'   [R Packages](https://r-pkgs.org).
#' * [use_test_helper()] to create a testthat helper file.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # create a new .R file below R/
#' use_r("coolstuff")
#'
#' # if `R/coolstuff.R` is active in a supported IDE, you can now do:
#' use_test()
#'
#' # if `tests/testthat/test-coolstuff.R` is active in a supported IDE, you can
#' # return to `R/coolstuff.R` with:
#' use_r()
#' }
use_r <- function(name = NULL, open = rlang::is_interactive()) {
  use_directory("R")

  path <- path("R", compute_name(name))
  edit_file(proj_path(path), open = open)

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
  edit_file(proj_path(path), open = open)

  invisible(TRUE)
}

#' Create or edit a test helper file
#'
#' This function helps create a test helper file, namely a file named
#'`tests/testthat/helper.R`. Test helper files are functions loaded with
#'`devtools::load_all()` that are  helpful to run tests.
#'
#' @inheritParams use_test
#' @seealso
#' * [use_test()] to create tests.
#' * The testthat vignette on special files
#' `vignette("special-files", package = "testthat")`.
#' @export
use_test_helper <- function(open = rlang::is_interactive()) {
  if (!uses_testthat()) {
    ui_abort(c(
      "Your package must use {.pkg testthat} to create a helper file"
    ))
  }

  target_path <- path("tests", "testthat", "helper.R")
  if (!file_exists(proj_path(target_path))) {
    ui_bullets(c(
      "_" = "Add functions to the testthat helper file.",
      "_" = "Run {.run devtools::load_all()} to load objects from helper files in
         your environment."
    ))
  }
  edit_file(proj_path(target_path), open = open)

  invisible(TRUE)
}

# helpers -----------------------------------------------------------------

compute_name <- function(name = NULL, ext = "R", error_call = caller_env()) {
  if (!is.null(name)) {
    check_file_name(name, call = error_call)

    if (path_ext(name) == "") {
      name <- path_ext_set(name, ext)
    } else if (path_ext(name) != ext) {
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

  dir <- path_dir(proj_rel_path(path))
  if (!dir %in% c("R", "src", "tests/testthat", "tests/testthat/_snaps")) {
    cli::cli_abort("Open file must be code, test, or snapshot.", call = error_call)
  }

  file <- path_file(path)
  if (dir == "tests/testthat") {
    if (file == "helper.R") {
      cli::cli_abort(c(
        "Can't call {.fn use_r} / {.fn use_test} when active file is \\
         {.path {pth('tests/testthat/helper.R')}}",
        i = "Supply {.arg name} or navigate to your  file."
        ),
        call = error_call
      )
    }
    file <- gsub("^test[-_]", "", file)
    file <- gsub("^helper[-_]", "", file)
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
