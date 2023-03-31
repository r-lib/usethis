#' Create or edit example files
#'
#' This function makes it easy to create paired R and example files,
#' using the convention that the examples for `R/foofy.R` should live
#' in `man/examples/example-foofy.R`. You can use it to create a new file
#' from scratch by supplying `name`, or if you use RStudio, you can call
#' to create (or navigate to) the example file based on the currently open
#' script.
#'
#' @section Including an example file in roxygen documentation:
#'
#' To add examples stored in an example file to roxygen documentation,
#' add the following line:
#'
#' ```{verbatim}
#' #' @example man/examples/example-<file>.R
#' ```
#'
#' @inheritParams use_r
#' @seealso [use_r()] and [use_test()] to create R and test files
#'   using a similar pattern.
#' @export
use_example <- function(name = NULL, open = rlang::is_interactive()) {
  # Determine file name
  name <- compute_name(name)

  # Determine path to `R/` file
  r_path <- path("R", name)

  # Determine path to example file
  use_directory(path("man", "examples"))
  example_name <- paste0("example-", name)
  example_path <- path("man", "examples", example_name)

  if (file_exists(r_path) && is_installed("roxygen2")) {
    # Check contents of roxygen tags in `R/` file
    roxygen_tags <- roxygen2::parse_file(r_path)
    roxygen_tags <- purrr::map(roxygen_tags, "tags")
    roxygen_tags <- purrr::flatten(roxygen_tags)

    # Check if `R/` file already has the path in its `@example` tag
    example_path_tags <- roxygen_tags[roxygen_tags$tag == "example"]
    example_path_tags <- purrr::map_chr(example_path_tags, "val")
    example_tag_already_present <- any(example_path_tags == example_path)

    # Check if `R/` file has examples in an `@examples` tag
    examples_tags <- roxygen_tags[roxygen_tags$tag == "examples"]
    preexisting_examples <- purrr::map_chr(examples_tags, "raw")
    preexisting_examples <- gsub("^\\n+", "", preexisting_examples)
  } else {
    # Defaults if `R/` file's roxygen tags cannot be read
    example_tag_already_present <- FALSE
    preexisting_examples <- character(0)
  }

  # Inform user to add `@example` tag with example path
  if (!example_tag_already_present) {
    if (length(preexisting_examples) > 0) {
      ui_todo(paste(
        "Replace", ui_code("@examples"),
        "in your roxygen documentation with the following line:"
      ))
    } else {
      ui_todo("Add the following line to your roxygen documentation:")
    }

    ui_line("#' @example {example_path}")
  }

  # If the example file doesn't already exist, copy examples from the `R/` file
  if (!file_exists(example_path)) {
    writeLines(preexisting_examples, example_path)
  }

  edit_file(proj_path(example_path), open = open)

  invisible(TRUE)
}
