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
    ),
    # we have enough color going on already, let's have black bullets
    ".bullets .bullet-*" = list(
      "text-exdent" = 2,
      before = function(x) paste0(cli::symbol$bullet, " ")
    ),
    span.field = list(transform = single_quote_if_no_color)
  )
}

single_quote_if_no_color <- function(x) quote_if_no_color(x, "'")

quote_if_no_color <- function(x, quote = "'") {
  # copied from googledrive
  # TODO: if a better way appears in cli, use it
  # @gabor says: "if you want to have before and after for the no-color case
  # only, we can have a selector for that, such as:
  # span.field::no-color
  # (but, at the time I write this, cli does not support this yet)
  if (cli::num_ansi_colors() > 1) {
    x
  } else {
    paste0(quote, x, quote)
  }
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

# inspired by gargle::gargle_map_cli() and gargle::bulletize()
usethis_map_cli <- function(x, ...) UseMethod("usethis_map_cli")

#' @export
usethis_map_cli.default <- function(x, ...) {
  ui_abort(c(
    "x" = "Don't know how to {.fun usethis_map_cli} an object of class
           {.obj_type_friendlys {x}}."
  ))
}

#' @export
usethis_map_cli.NULL <- function(x, ...) NULL

#' @export
usethis_map_cli.character <- function(x,
                                      template = "{.val <<x>>}",
                                      .open = "<<", .close = ">>",
                                      ...) {
  as.character(glue(template, .open = .open, .close = .close))
}

bulletize <- function(x, bullet = "*", n_show = 5, n_fudge = 2) {
  n <- length(x)
  n_show_actual <- compute_n_show(n, n_show, n_fudge)
  out <- utils::head(x, n_show_actual)
  n_not_shown <- n - n_show_actual

  out <- set_names(out, rep_along(out, bullet))

  if (n_not_shown == 0) {
    out
  } else {
    c(out, " " = glue("{cli::symbol$ellipsis} and {n_not_shown} more"))
  }
}

# I don't want to do "... and x more" if x is silly, i.e. 1 or 2
compute_n_show <- function(n, n_show_nominal = 5, n_fudge = 2) {
  if (n > n_show_nominal && n - n_show_nominal > n_fudge) {
    n_show_nominal
  } else {
    n
  }
}

kv_line <- function(key, value, .envir = parent.frame()) {
  key <- cli::format_inline(key, .envir = .envir)

  value <- value %||% ui_special()

  if (inherits(value, "AsIs")) {
    value <- cli::format_inline(value, .envir = .envir)
  } else {
    value <- cli::format_inline("{.val {value}}")
  }

  ui_bullets(c("*" = "{key}: {value}"))
}

ui_special <- function(x = "unset") {
  I(glue("{cli::col_grey('<[x]>')}", .open = "[", .close = "]"))
}

