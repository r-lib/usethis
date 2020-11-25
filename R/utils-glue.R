# wrappers that apply as.character() to glue functions

glue_chr <- function(...) {
  as.character(glue::glue(..., .envir = parent.frame(1)))
}

glue_data_chr <- function(.x, ...) {
  as.character(glue::glue_data(.x = .x, ..., .envir = parent.frame(1)))
}
