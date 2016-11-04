use_template <- function(template,
                         save_as = template,
                         data = list(),
                         ignore = FALSE,
                         open = FALSE,
                         base_path = "."
                         ) {

  render_template(template, save_as, data = data, base_path = base_path)

  if (ignore) {
    message("* Adding `", save_as, "` to `.Rbuildignore`.")
    use_build_ignore(save_as, base_path = base_path)
  }

  if (open) {
    message("* Modify `", save_as, "`.")
    open_in_rstudio(save_as, base_path = base_path)
  }

  invisible(TRUE)
}

render_template <- function(template_name, save_as, data = list(), base_path = ".") {
  template_path <- system.file("templates", template_name, package = "usethis")
  if (identical(template_path, "")) {
    stop("Could not find template '", template_name, "'", call. = FALSE)
  }

  path <- file.path(base_path, save_as)
  if (!can_overwrite(path)) {
    stop("'", save_as, "' already exists.", call. = FALSE)
  }

  message("* Creating `", save_as, "` from template.")
  template <- whisker::whisker.render(readLines(template_path), data)
  writeLines(template, path)
}

package_data <- function(base_path = ".") {
  desc <- desc::description$new(base_path)
  as.list(desc$get(desc$fields()))
}
