# opening act of an eventual transition away from the ui_*() functions and towards
# the cli-mediated UI we're using in other packages
# TODO: get rid of this because it doesn't honor usethis.quiet
ui_cli_inform <- function(..., .envir = parent.frame()) {
  if (!is_quiet()) {
    cli::cli_inform(..., .envir = .envir)
  }
  invisible()
}

usethis_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  #cli::cli_div(theme = usethis_theme())
  cli::cli_abort(
    message,
    class = c(class, "usethis_error"),
    .envir = .envir,
    ...
  )
}
