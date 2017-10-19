#' Create README files.
#'
#' Creates skeleton README files with sections for
#' \itemize{
#' \item a high-level description of the package and its goals
#' \item R code to install from GitHub, if GitHub usage detected
#' \item a basic example
#' }
#' Use `Rmd` if you want a rich intermingling of code and data. Use
#' `md` for a basic README. `README.Rmd` will be automatically
#' added to `.Rbuildignore`. The resulting README is populated with default
#' YAML frontmatter and R fenced code blocks (`md`) or chunks (`Rmd`).
#'
#' @inheritParams use_template
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
use_readme_rmd <- function(open = TRUE) {
  check_installed("rmarkdown")

  data <- project_data()
  data$Rmd <- TRUE

  use_template(
    if (is_package()) "omni-README" else "project-README.Rmd",
    "README.Rmd",
    data = data,
    ignore = TRUE,
    open = open
  )

  if (uses_git() && !file.exists(proj_get(), ".git", "hooks", "pre-commit")) {
    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh")
    )
  }

  invisible(TRUE)
}

#' @export
#' @rdname use_readme_rmd
use_readme_md <- function(open = TRUE) {
  use_template(
    "omni-README",
    "README.md",
    data = package_data(),
    open = open
  )
}
