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
use_readme_rmd <- function(base_path = ".", open = TRUE) {
  check_installed("rmarkdown")

  data <- package_data(base_path)
  data$Rmd <- TRUE

  use_template(
    "omni-README",
    "README.Rmd",
    data = data,
    ignore = TRUE,
    open = open,
    base_path = base_path
  )

  if (uses_git(base_path)) {
    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh"),
      base_path = base_path
    )
  }

  invisible(TRUE)
}

#' @export
#' @rdname use_readme_rmd
use_readme_md <- function(base_path = ".", open = TRUE) {
  use_template(
    "omni-README",
    "README.md",
    data = package_data(base_path),
    open = open,
    base_path = base_path
  )
}
