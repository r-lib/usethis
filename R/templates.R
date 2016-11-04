use_template <- function(template, save_as = template, data = list(),
                         ignore = FALSE, open = FALSE, base_path = ".") {
  pkg <- as.package(pkg)

  path <- file.path(pkg$path, save_as)
  if (!can_overwrite(path)) {
    stop("`", save_as, "` already exists.", call. = FALSE)
  }

  template_path <- system.file("templates", template, package = "devtools",
    mustWork = TRUE)
  template_out <- whisker::whisker.render(readLines(template_path), data)

  message("* Creating `", save_as, "` from template.")
  writeLines(template_out, path)

  if (ignore) {
    message("* Adding `", save_as, "` to `.Rbuildignore`.")
    use_build_ignore(save_as, pkg = pkg)
  }

  if (open) {
    message("* Modify `", save_as, "`.")
    open_in_rstudio(path)
  }

  invisible(TRUE)
}

open_in_rstudio <- function(path) {
  if (!rstudioapi::isAvailable())
    return()

  if (!rstudioapi::hasFun("navigateToFile"))
    return()

  rstudioapi::navigateToFile(path)

}

can_overwrite <- function(path) {
  name <- basename(path)

  if (!file.exists(path)) {
    TRUE
  } else if (interactive() && !yesno("Overwrite `", name, "`?")) {
    TRUE
  } else {
    FALSE
  }
}
