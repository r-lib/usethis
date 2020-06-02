can_overwrite <- function(path) {
  if (!file_exists(path)) {
    return(TRUE)
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
  path_ext_set(x_base, ext)
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

check_installed <- function(pkg) {
  if (!is_installed(pkg)) {
    ui_stop("Package {ui_value(pkg)} required. Please install before re-trying.")
  }
}

is_installed <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}

## mimimalist, type-specific purrr::pluck()'s
pluck_chr <- function(l, what) vapply(l, `[[`, character(1), what)

interactive <- function() {
  ui_stop(
    "Internal error: use rlang's {ui_code('is_interactive()')} \\
     instead of {ui_code('base::interactive()')}"
  )
}

indent <- function(x, first = "  ", indent = first) {
  x <- gsub("\n", paste0("\n", indent), x)
  paste0(first, x)
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
