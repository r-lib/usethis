#' Create README files
#'
#' @description
#' Creates skeleton README files with possible stubs for
#' * a high-level description of the project/package and its goals
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
#' If the current project is a Git repo, then `use_readme_rmd()` automatically
#' configures a pre-commit hook that helps keep `README.Rmd` and `README.md`,
#' synchronized. The hook creates friction if you try to commit when
#' `README.Rmd` has been edited more recently than `README.md`. If this hook
#' causes more problems than it solves for you, it is implemented in
#' `.git/hooks/pre-commit`, which you can modify or even delete.
#'
#' @inheritParams use_template
#' @seealso The [other markdown files
#'   section](https://r-pkgs.org/other-markdown.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
use_readme_rmd <- function(open = rlang::is_interactive()) {
  check_is_project()
  check_installed("rmarkdown")

  is_pkg <- is_package()
  repo_spec <- tryCatch(target_repo_spec(ask = FALSE), error = function(e) NULL)
  nm <- if (is_pkg) "Package" else "Project"
  data <- list2(
    !!nm := project_name(),
    Rmd = TRUE,
    on_github = !is.null(repo_spec),
    github_spec = repo_spec
  )

  new <- use_template(
    if (is_pkg) "package-README" else "project-README",
    "README.Rmd",
    data = data,
    ignore = is_pkg,
    open = open
  )
  if (!new) {
    return(invisible(FALSE))
  }

  if (is_pkg && !data$on_github) {
    ui_bullets(c(
      "_" = "Update {.path {pth('README.Rmd')}} to include installation instructions."
    ))
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
  check_is_project()
  is_pkg <- is_package()
  repo_spec <- tryCatch(target_repo_spec(ask = FALSE), error = function(e) NULL)
  nm <- if (is_pkg) "Package" else "Project"
  data <- list2(
    !!nm := project_name(),
    Rmd = FALSE,
    on_github = !is.null(repo_spec),
    github_spec = repo_spec
  )

  new <- use_template(
    if (is_pkg) "package-README" else "project-README",
    "README.md",
    data = data,
    open = open
  )

  if (is_pkg && !data$on_github) {
    ui_bullets(c(
      "_" = "Update {.path {pth('README.md')}} to include installation instructions."
    ))
  }

  invisible(new)
}
