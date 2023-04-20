# opening act of an eventual transition away from the ui_*() functions and towards
# the cli-mediated UI we're using in other packages

usethis_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  #cli::cli_div(theme = usethis_theme())
  cli::cli_abort(
    message,
    class = c(class, "usethis_error"),
    .envir = .envir,
    ...
  )
}
