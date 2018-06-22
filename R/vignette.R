#' Create a vignette
#'
#' Performs general set up for vignettes and initializes a new individual
#' vignette:
#' * Adds needed packages to `DESCRIPTION`
#' * Adds `inst/doc` to `.gitignore` so built vignettes aren't tracked
#' * Creates a new draft `.Rmd` vignette in `vignettes/` and, if possible,
#' opens it for editing
#'
#' @param name Base for file name to use for new vignette. Should consist only
#'   of numbers, letters, _ and -. I recommend using lower case.
#' @export
#' @examples
#' \dontrun{
#' use_vignette("how-to-do-stuff")
#' }
use_vignette <- function(name) {
  check_is_package("use_vignette()")
  if (missing(name)) {
    stop_glue("Argument {code('name')} is missing, with no default.")
  }
  check_installed("rmarkdown")

  use_dependency("knitr", "Suggests")
  use_description_field("VignetteBuilder", "knitr")
  use_dependency("rmarkdown", "Suggests")

  use_directory("vignettes")
  use_git_ignore(c("*.html", "*.R"), directory = "vignettes")
  use_git_ignore("inst/doc")

  path <- proj_path("vignettes", asciify(name), ext = "Rmd")

  done("Creating {value(proj_rel_path(path))}")
  rmarkdown::draft(
    path, "html_vignette", "rmarkdown",
    create_dir = FALSE, edit = FALSE
  )
  edit_file(path)
}
