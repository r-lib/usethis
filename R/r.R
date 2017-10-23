#' Create a new R file.
#'
#' @param name File name, without extension.
#' @export
use_r <- function(name) {
  check_file_name(name)

  use_directory("R")
  edit_file(proj_get(), paste0("R/", name, ".R"))

  invisible(TRUE)
}

check_file_name <- function(name) {
  if (!valid_file_name(name)) {
    stop(
      value(name), " is not a valid file name. It should:\n",
      "* Contain only ASCII letters, numbers, '-', and '_'\n",
      call. = FALSE
    )
  }
}

valid_file_name <- function(x) {
  grepl("^[[:alpha:]_-]+$", x)
}
