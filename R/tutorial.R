#' Create a learnr tutorial
#'
#' Creates a new tutorial below `inst/tutorials/`. Tutorials are interactive R
#' Markdown documents built with the [`learnr`
#' package](https://rstudio.github.io/learnr/index.html). `use_tutorial()` does
#' this setup:
#'   * Adds learnr to Suggests in `DESCRIPTION`.
#'   * Gitignores `inst/tutorials/*.html` so you don't accidentally track
#'     rendered tutorials.
#'   * Creates a new `.Rmd` tutorial from a template and, optionally, opens it
#'     for editing.
#'   * Adds new `.Rmd` to `.Rbuildignore`.
#'
#' @param name Base for file name to use for new `.Rmd` tutorial. Should consist
#'   only of numbers, letters, `_` and `-`. We recommend using lower case.
#' @param title The human-facing title of the tutorial.
#' @inheritParams use_template
#' @seealso The [learnr package
#'   documentation](https://rstudio.github.io/learnr/index.html).
#' @export
#' @examples
#' \dontrun{
#' use_tutorial("learn-to-do-stuff", "Learn to do stuff")
#' }
use_tutorial <- function(name, title, open = rlang::is_interactive()) {
  stopifnot(is_string(name))
  stopifnot(is_string(title))

  dir_path <- path("inst", "tutorials", name)
  dir_create(dir_path)

  use_directory(dir_path)
  use_git_ignore("*.html", directory = dir_path)
  use_dependency("learnr", "Suggests")

  path <- path(dir_path, asciify(name), ext = "Rmd")
  new <- use_template(
    "tutorial-template.Rmd",
    save_as = path,
    data = list(tutorial_title = title),
    ignore = FALSE,
    open = open
  )

  invisible(new)
}
