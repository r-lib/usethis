#' Create README files
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
#' @seealso The [important files
#'   section](https://r-pkgs.org/release.html#important-files) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
use_readme_rmd <- function(open = rlang::is_interactive()) {
  check_installed("rmarkdown")

  data <- project_data()
  data$Rmd <- TRUE
  if (uses_github()) {
    data$github <- list(
      owner = github_owner(),
      repo = github_repo()
    )
  }

  new <- use_template(
    if (is_package()) "package-README" else "project-README",
    "README.Rmd",
    data = data,
    ignore = is_package(),
    open = open
  )
  if (!new) {
    return(invisible(FALSE))
  }

  if (uses_git()) {
    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh")
    )
  }

  invisible(TRUE)
}

#' @export
#' @rdname use_readme_rmd
use_readme_md <- function(open = rlang::is_interactive()) {
  use_template(
    if (is_package()) "package-README" else "project-README",
    "README.md",
    data = project_data(),
    open = open
  )
}
