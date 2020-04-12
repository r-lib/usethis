#' Use a specific GitHub action
#'
#' Use a specific action, either one of the example actions from
#' [r-lib/actions/examples](https://github.com/r-lib/actions/tree/master/examples)
#' or a custom action given by the `url` parameter.
#'
#' @inheritParams use_template
#' @param name Name of the GitHub action, with or without `.yaml` extension
#' @param url The full URL to the GitHub Actions yaml file.
#'   By default, the corresponding action in https://github.com/r-lib/actions
#'   will be used.
#' @param save_as Name of the actions file. Defaults to `basename(url)`
#'   for `use_github_action()`.
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

  # Check if a custom URL is being used.
  if (is.null(url)) {
    stopifnot(is_string(name))

    # Append a `.yaml` extension if needed
    if (!grepl("[.]yaml$", name)) {
      name <- paste0(name, ".yaml")
    }

    url <- glue("https://raw.githubusercontent.com/r-lib/actions/master/examples/{name}")
  } else {
    stopifnot(is_string(url))
  }

  if (is.null(save_as)) {
    save_as <- basename(url)
  }

  contents <- read_utf8(url)

  use_dot_github(ignore = ignore)

  save_as <- path(".github", "workflows", save_as)
  create_directory(dirname(proj_path(save_as)))

  new <- write_over(proj_path(save_as), contents)

  if (open && new) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}

#' @section `use_github_action_check_release()`:
#' This action installs the latest release R version on macOS and runs `R CMD check`
#'   via the [rcmdcheck](https://github.com/r-lib/rcmdcheck) package.
#' @rdname use_github_action
#' @export
use_github_action_check_release <- function(save_as = "R-CMD-check.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("check-release.yaml", save_as = save_as, ignore = ignore, open = open)

  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_check_standard()`:
#' This action runs R CMD check
#'   via the [rcmdcheck](https://github.com/r-lib/rcmdcheck) package on the
#'   three major OSs (linux, macOS and Windows) on the release version of R and
#'   R-devel. This action is most appropriate when you plan to eventually
#'   submit your package to CRAN or Bioconductor.
#' @rdname use_github_action
#' @export
use_github_action_check_standard <- function(save_as = "R-CMD-check.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("check-standard.yaml", save_as = save_as, ignore = ignore, open = open)

  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_check_full()`:
#' This action installs the last 5 minor R versions and runs R CMD check
#'   via the [rcmdcheck](https://github.com/r-lib/rcmdcheck) package on the
#'   three major OSs (linux, macOS and Windows). This action is what the
#'   tidyverse teams uses on their repositories, but is overkill for less
#'   widely used packages, which are better off using the simpler
#'   `use_github_action_check_release()`.
#' @rdname use_github_action
#' @export
use_github_action_check_full <- function(save_as = "R-CMD-check.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("check-full.yaml", save_as = save_as, ignore = ignore, open = open)

  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_pr_commands()`:
#' This workflow enables the use of 2 R specific commands in pull request
#'   issue comments. `/document` will use
#'   [roxygen2](https://roxygen2.r-lib.org/) to rebuild the documentation for
#'   the package and commit the result to the pull request. `/style` will use
#'   [styler](https://styler.r-lib.org/) to restyle your package.
#' @rdname use_github_action
#' @export
use_github_action_pr_commands <- function(save_as = "pr-commands.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("pr-commands.yaml", save_as = save_as, ignore = ignore, open = open)
}
