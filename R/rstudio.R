#' Use RStudio
#'
#' Creates an `.Rproj` file and adds RStudio files to `.gitignore`
#' and `.Rbuildignore`.
#'
#' @inheritParams use_template
#' @export
use_rstudio <- function() {
  use_template(
    "template.Rproj",
    paste0(project_name(), ".Rproj")
  )

  use_git_ignore(".Rproj.user")
  if (is_package()) {
    use_build_ignore(c("^.*\\.Rproj$", "^\\.Rproj\\.user$"), escape = FALSE)
  }

  invisible(TRUE)
}


# Is base_path open in RStudio?
in_rstudio <- function(base_path = proj_get()) {
  if (!rstudioapi::isAvailable())
    return(FALSE)

  if (!rstudioapi::hasFun("getActiveProject"))
    return(FALSE)

  proj <- rstudioapi::getActiveProject()

  normalizePath(proj) == normalizePath(base_path)
}
