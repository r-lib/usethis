#' Use a specific GitHub action
#'
#' Use a specific action, either one of the example actions from
#'   [r-lib/actions/examples](https://github.com/r-lib/actions/tree/master/examples) or a custom action
#'   given by the `url` parameter.
#'
#' @inheritParams github_actions
#' @param name Name of the GitHub action, with or without `.yaml` extension
#' @param url The full URL to the GitHub Actions yaml file.
#'   By default, the corresponding action in https://github.com/r-lib/actions
#'   will be used.
#' @param save_as Name of the actions file. Defaults to `basename(url)`.
#'
#' @seealso [github_actions] for generic workflows.
#'
#' @export
#' @inheritParams use_template
use_github_action <- function(name,
                              url = NULL,
                              save_as = NULL,
                              ignore = TRUE,
                              open = FALSE) {

  # Append a `.yaml` extension if needed
  stopifnot(is_string(name))

  if (!grepl("[.]yaml$", name)) {
    name <- paste0(name, ".yaml")
  }

  if (is.null(url)) {
    url <- glue("https://raw.githubusercontent.com/r-lib/actions/master/examples/{name}")
  }

  if (is.null(save_as)) {
    save_as <- basename(url)
  }

  contents <- readLines(url)

  save_as <- path(".github", "workflows", save_as)

  create_directory(dirname(proj_path(save_as)))
  new <- write_over(proj_path(save_as), contents)

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open && new) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}
