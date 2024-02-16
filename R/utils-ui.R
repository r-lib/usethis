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

ui_bullets <- function(text, .envir = parent.frame()) {
  if (is_quiet()) {
    return(invisible())
  }
  cli::cli_div(theme = usethis_theme())
  cli::cli_bullets(text, .envir = .envir)
}

ui_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
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

ui_code_snippet <- function(x,
                            copy = rlang::is_interactive(),
                            language = c("R", ""),
                            interpolate = TRUE,
                            .envir = parent.frame()) {
  language <- arg_match(language)

  x <- glue_collapse(x, "\n")
  if (interpolate) {
    x <- glue(x, .envir = .envir)
    # what about literal `{` or `}`?
    # use `interpolate = FALSE`, if appropriate
    # double them, i.e. `{{` or `}}`
    # open issue/PR about adding `.open` and `.close`
  }

  if (!is_quiet()) {
    # the inclusion of `.envir = .envir` leads to test failure
    # I'm consulting with Gabor on this
    # leaving it out seems fine for my use case
    # cli::cli_code(indent(x), language = language, .envir = .envir)
    cli::cli_code(indent(x), language = language)
  }

  if (copy && clipr::clipr_available()) {
    x_no_ansi <- cli::ansi_strip(x)
    clipr::write_clip(x_no_ansi)
    style_subtle <- cli::combine_ansi_styles(
      cli::make_ansi_style("grey"),
      cli::style_italic
    )
    ui_bullets(c(" " = style_subtle("[Copied to clipboard]")))
  }

  invisible(x)
}
