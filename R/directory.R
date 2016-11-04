use_directory <- function(path, ignore = FALSE, pkg = ".") {
  pkg <- as.package(pkg)
  pkg_path <- file.path(pkg$path, path)

  if (file.exists(pkg_path)) {
    if (!is_dir(pkg_path)) {
      stop("`", path, "` exists but is not a directory.", call. = FALSE)
    }
  } else {
    message("* Creating `", path, "`.")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE)
  }

  if (ignore) {
    message("* Adding `", path, "` to `.Rbuildignore`.")
    use_build_ignore(path, pkg = pkg)
  }

  invisible(TRUE)
}
