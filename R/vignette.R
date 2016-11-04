#' @section \code{use_vignette}:
#' Adds needed packages to \code{DESCRIPTION}, and creates draft vignette
#' in \code{vignettes/}. It adds \code{inst/doc} to \code{.gitignore}
#' so you don't accidentally check in the built vignettes.
#' @param name File name to use for new vignette. Should consist only of
#'   numbers, letters, _ and -. I recommend using lower case.
#' @export
#' @rdname infrastructure
use_vignette <- function(name, pkg = ".") {
  pkg <- as.package(pkg)
  check_suggested("rmarkdown")

  add_desc_package(pkg, "Suggests", "knitr")
  add_desc_package(pkg, "Suggests", "rmarkdown")
  add_desc_package(pkg, "VignetteBuilder", "knitr")

  use_directory("vignettes", pkg = pkg)
  use_git_ignore("inst/doc", pkg = pkg)

  path <- file.path(pkg$path, "vignettes", paste0(name, ".Rmd"))
  rmarkdown::draft(path, "html_vignette", "rmarkdown",
    create_dir = FALSE, edit = FALSE)

  open_in_rstudio(path)
}
