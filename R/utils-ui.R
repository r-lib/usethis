usethis_theme <- function() {
  list(
    # add a "todo" bullet, which is intended to be seen as an unchecked checkbox
    ".bullets .bullet-_" = list(
      "text-exdent" = 2,
      before = function(x) paste0(cli::col_red(cli::symbol$checkbox_off), " ")
    ),
    # historically, usethis has used yellow for this
    ".bullets .bullet-i" = list(
      "text-exdent" = 2,
      before = function(x) paste0(cli::col_yellow(cli::symbol$info), " ")
    )
  )
}

ui_cli_bullets <- function(text, .envir = parent.frame()) {
  if (is_quiet()) {
    return(invisible())
  }
  cli::cli_div(theme = usethis_theme())
  cli::cli_bullets(text, .envir = .envir)
}

usethis_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  cli::cli_div(theme = usethis_theme())
  cli::cli_abort(
    message,
    class = c(class, "usethis_error"),
    .envir = .envir,
    ...
  )
}

ui_path_impl <- function(x, base = NULL) {
  is_directory <- is_dir(x) | grepl("/$", x)
  if (is.null(base)) {
    x <- proj_rel_path(x)
  } else if (!identical(base, NA)) {
    x <- path_rel(x, base)
  }

  # rationalize trailing slashes
  x <- path_tidy(x)
  x[is_directory] <- paste0(x[is_directory], "/")

  unclass(x)
}

# shorter form for compactness, because this is typical usage:
# ui_bullets("blah blah {.path {pth(some_path)}}")
pth <- ui_path_impl
