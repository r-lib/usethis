#' Create a learnr tutorial
#'
#' Creates a new tutorial in `inst/tutorials`. Tutorials are interactive R
#' Markdown documents built with the `learnr` package.
#'
#' @section General setup:
#' * Adds needed packages to `DESCRIPTION`.
#' * Adds `inst/tutorials/*.html` to `.gitignore` so
#'   you never accidentally track rendered tutorials.
#' @param name Base for file name to use for new tutorials. Should consist only
#'   of numbers, letters, _ and -. We recommend using lower case.
#' @param title The title of the tutorial
#' @inheritParams use_template
#' @seealso The [learnr package documentation](https://rstudio.github.io/learnr/index.html).
#' @export
#' @examples
#' \dontrun{
#' use_tutorial("learn-to-do-stuff", "Learn to do stuff")
#' }
use_tutorial <- function(name, title, open = interactive()) {
  stopifnot(is_string(name))
  stopifnot(is_string(title))

  dir_path <- path("inst", "tutorials")

  use_directory(dir_path)
  use_git_ignore("*.html", directory = dir_path)
  use_dependency("learnr", "Suggests")

  path <- path(dir_path, asciify(name), ext = "Rmd")

  data <- project_data()
  data$tutorial_title <- title

  new <- use_template(
    "tutorial-template.Rmd",
    save_as = path,
    data = data,
    ignore = TRUE,
    open = open
  )

  invisible(new)
}
