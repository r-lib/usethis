#' Create README files
#'
#' @description
#' Creates skeleton README files with sections for
#' * a high-level description of the package and its goals
#' * R code to install from GitHub, if GitHub usage detected
#' * a basic example
#'
#' Use `Rmd` if you want a rich intermingling of code and output. Use `md` for a
#' basic README. `README.Rmd` will be automatically added to `.Rbuildignore`.
#' The resulting README is populated with default YAML frontmatter and R fenced
#' code blocks (`md`) or chunks (`Rmd`).
#'
#' If you use `Rmd`, you'll still need to render it regularly, to keep
#' `README.md` up-to-date. `devtools::build_readme()` is handy for this. You
#' could also use GitHub Actions to re-render `README.Rmd` every time you push.
#' An example workflow can be found in the `examples/` directory here:
#' <https://github.com/r-lib/actions/>.
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
  data$on_github <- origin_is_on_github()

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
