#' Create a vignette
#'
#' Adds needed packages to `DESCRIPTION`, and creates draft vignette
#' in `vignettes/`. It adds `inst/doc` to `.gitignore`
#' so you don't accidentally check in the built vignettes.
#'
#' @param name File name to use for new vignette. Should consist only of
#'   numbers, letters, _ and -. I recommend using lower case.
#' @export
#' @inheritParams use_template
use_vignette <- function(name) {
  check_installed("rmarkdown")

  use_dependency("knitr", "Suggests")
  use_description_field("VignetteBuilder", "knitr")
  use_dependency("rmarkdown", "Suggests")

  use_directory("vignettes")
  use_git_ignore(c("*.html", "*.R"), "vignettes")
  use_git_ignore("inst/doc")

  path <- file.path("vignettes", slug(name, ".Rmd"))

  done("Creating '", path, "'")
  rmarkdown::draft(file.path(proj_get(), path), "html_vignette", "rmarkdown",
    create_dir = FALSE, edit = FALSE)
  edit_file(proj_get(), path)
}
