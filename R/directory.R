use_directory <- function(path, ignore = FALSE, base_path = ".") {
  pkg_path <- file.path(base_path, path)

  if (file.exists(pkg_path)) {
    if (!is_dir(pkg_path)) {
      stop("'", path, "' exists but is not a directory.", call. = FALSE)
    }
  } else {
    message("* Creating '", path, "'.")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE)
  }

  if (ignore) {
    use_build_ignore(path, base_path = base_path)
  }

  invisible(TRUE)
}
