#' Create README files
#'
#' @description
#' Creates skeleton README files with possible stubs for
#' * a high-level description of the project/package and its goals
#' * R code to install from GitHub, if GitHub usage detected
#' * a basic example
#'
#' Use `qmd` or `Rmd` if you want a rich intermingling of code and output.
#' Use `md` for a basic README. `README.qmd` and `README.Rmd` will be
#' automatically added to `.Rbuildignore`. The resulting README is populated
#' with default YAML frontmatter and R fenced code blocks (`md`) or
#' chunks (`qmd`, `Rmd`).
#'
#' If you use `qmd` or `Rmd`, you'll still need to render it regularly, to
#' keep `README.md` up-to-date. `devtools::build_readme()` is handy for
#' this. You could also use GitHub Actions to re-render `README.qmd` or
#' `README.Rmd` every time you push. An example workflow can be found in
#' the `examples/` directory here:
#' <https://github.com/r-lib/actions/>.
#'
#' If the current project is a Git repo, then `use_readme_qmd()` and
#' `use_readme_rmd()` automatically configure a pre-commit hook that helps
#' keep `README.md` synchronized with the source file. The hook creates
#' friction if you try to commit when `README.qmd` or `README.Rmd` has
#' been edited more recently than `README.md`. If this hook causes more
#' problems than it solves for you, it is implemented in
#' `.git/hooks/pre-commit`, which you can modify or even delete.
#'
#' @inheritParams use_template
#' @seealso The [other markdown files
#'   section](https://r-pkgs.org/other-markdown.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_readme_qmd()
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

  ui_bullets(c(
    "_" = "Use {.fun devtools::build_readme} to render {.path {pth('README.Rmd')}}."
  ))

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
use_readme_qmd <- function(open = rlang::is_interactive()) {
  check_is_project()

  is_pkg <- is_package()
  repo_spec <- tryCatch(target_repo_spec(ask = FALSE), error = function(e) NULL)
  nm <- if (is_pkg) "Package" else "Project"
  data <- list2(
    !!nm := project_name(),
    on_github = !is.null(repo_spec),
    github_spec = repo_spec
  )

  new <- use_template(
    if (is_pkg) "package-README-qmd" else "project-README-qmd",
    "README.qmd",
    data = data,
    ignore = is_pkg,
    open = open
  )
  if (!new) {
    return(invisible(FALSE))
  }

  if (is_pkg && !data$on_github) {
    ui_bullets(c(
      "_" = "Update {.path {pth('README.qmd')}} to include installation instructions."
    ))
  }

  if (file_exists(proj_path("README.Rmd"))) {
    ui_bullets(c(
      "!" = "A pre-existing {.path {pth('README.Rmd')}} was found.",
      "_" = "Migrate its content to {.path {pth('README.qmd')}}.",
      "_" = "Delete {.path {pth('README.Rmd')}} when the migration is done."
    ))
  }

  ui_bullets(c(
    "_" = "Use {.fun devtools::build_readme} to render {.path {pth('README.qmd')}}."
  ))

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
