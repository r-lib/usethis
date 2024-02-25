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
    ui_abort("{.code {nm}} must be a list, not {.obj_type_friendly {x}}.")
  }
  if (!is_dictionaryish(x)) {
    ui_abort(
      "Names of {.code {nm}} must be non-missing, non-empty, and non-duplicated.")
  }
  x
}

dots <- function(...) {
  eval(substitute(alist(...)))
}

asciify <- function(x) {
  check_character(x)
  gsub("[^a-zA-Z0-9_-]+", "-", x)
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

# Needed for mocking
is_installed <- function(pkg) {
  rlang::is_installed(pkg)
}

isFALSE <- function(x) {
  identical(x, FALSE)
}

isNA <- function(x) {
  length(x) == 1 && is.na(x)
}

path_first_existing <- function(paths) {
  # manual loop with explicit use of `[[` to retain "fs" class
  for (i in seq_along(paths)) {
    path <- paths[[i]]
    if (file_exists(path)) {
      return(path)
    }
  }

  NULL
}

is_online <- function(host) {
  bare_host <- sub("^https?://(.*)$", "\\1", host)
  !is.null(curl::nslookup(bare_host, error = FALSE))
}

year <- function() format(Sys.Date(), "%Y")

pluck_lgl <- function(.x, ...) {
  as.logical(purrr::pluck(.x, ..., .default = NA))
}

pluck_chr <- function(.x, ...) {
  as.character(purrr::pluck(.x, ..., .default = NA))
}

pluck_int <- function(.x, ...) {
  as.integer(purrr::pluck(.x, ..., .default = NA))
}

is_windows <- function() {
  .Platform$OS.type == "windows"
}

# For stability of `stringsAsFactors` across versions
data.frame <- function(..., stringsAsFactors = FALSE) {
  base::data.frame(..., stringsAsFactors = stringsAsFactors)
}

# wrapper around check_name() from import-standalone-types-check.R
# for the common case when NULL is allowed (often default)
maybe_name <- function(x, ..., arg = caller_arg(x),
                       call = caller_env()) {
  check_name(x, ..., allow_null = TRUE,
             arg = arg, call = call)
}
