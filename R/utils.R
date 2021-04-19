can_overwrite <- function(path) {
  if (!file_exists(path)) {
    return(TRUE)
  }

  if (getOption("usethis.overwrite", FALSE)) {
    # don't activate a project
    # don't assume `path` is in the active project
    if (is_in_proj(path) && uses_git()) {      # path is in active project
      return(TRUE)
    }
    if (possibly_in_proj(path) &&              # path is some other project
        with_project(proj_find(path), uses_git(), quiet = TRUE)) {
      return(TRUE)
    }
  }

  if (is_interactive()) {
    ui_yeah("Overwrite pre-existing file {ui_path(path)}?")
  } else {
    FALSE
  }
}

check_is_named_list <- function(x, nm = deparse(substitute(x))) {
  if (!is_list(x)) {
    bad_class <- paste(class(x), collapse = "/")
    ui_stop("{ui_code(nm)} must be a list, not {ui_value(bad_class)}.")
  }
  if (!is_dictionaryish(x)) {
    ui_stop(
      "Names of {ui_code(nm)} must be non-missing, non-empty, and non-duplicated."
    )
  }
  x
}

dots <- function(...) {
  eval(substitute(alist(...)))
}

asciify <- function(x) {
  stopifnot(is.character(x))
  gsub("[^a-zA-Z0-9_-]+", "-", x)
}

slug <- function(x, ext) {
  x_base <- path_ext_remove(x)
  x_ext <- path_ext(x)
  ext <- if (identical(tolower(x_ext), tolower(ext))) x_ext else ext
  as.character(path_ext_set(x_base, ext))
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

# Needed for mocking
is_installed <- function(pkg) {
  rlang::is_installed(pkg)
}
check_installed <- function(pkg) {
  rlang::check_installed(pkg)
}

interactive <- function() {
  ui_stop(
    "Internal error: use rlang's {ui_code('is_interactive()')} \\
     instead of {ui_code('base::interactive()')}"
  )
}

on.exit <- function(...) {
  ui_stop("
    Internal error: use withr's {ui_code('defer()')} and friends, \\
    instead of {ui_code('base::on.exit()')}")
}

isFALSE <- function(x) {
  identical(x, FALSE)
}

isNA <- function(x) {
  length(x) == 1 && is.na(x)
}

path_first_existing <- function(...) {
  paths <- path(...)
  for (path in paths) {
    if (file_exists(path)) {
      return(path)
    }
  }

  NULL
}

is_online <- function(host) {
  !is.null(curl::nslookup(host, error = FALSE))
}

year <- function() format(Sys.Date(), "%Y")

pluck_lgl <- function(.x, ...) {
  as_logical(purrr::pluck(.x, ..., .default = NA))
}

pluck_chr <- function(.x, ...) {
  as_character(purrr::pluck(.x, ..., .default = NA))
}

pluck_int <- function(.x, ...) {
  as_integer(purrr::pluck(.x, ..., .default = NA))
}

is_windows <- function() {
  .Platform$OS.type == "windows"
}
