#' Create README files
#'
#' @description
#' Creates skeleton README files with possible stubs for
#' * a high-level description of the project/package and its goals
#' * R code to install from GitHub, if GitHub usage detected
#' * a basic example
#'
#' Use `Quarto` or `Rmd` if you want a rich intermingling of code and output. Use `md` for a
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
  use_readme("Rmd", open = open)
}

#' @export
#' @rdname use_readme_rmd
use_readme_md <- function(open = rlang::is_interactive()) {
  use_readme("md", open = open)
}

#' @export
#' @rdname use_readme_rmd
use_readme_qmd <- function(open = rlang::is_interactive()) {
  # TODO: fail if README.RMD exists
  # cli::cli_abort("Can't have both {.file README.Rmd} and {.file README.qmd}.")
  use_readme("qmd", open = open)
}

#' @noRd
use_readme <- function(
  fmt = c("Rmd", "md", "qmd"),
  open = rlang::is_interactive()
) {
  check_is_project()
  fmt <- rlang::arg_match(fmt)
  if (fmt == "Rmd") {
    check_installed("rmarkdown")
  }
  if (fmt == "qmd") {
    check_installed("quarto")
  }

  is_pkg <- is_package()
  repo_spec <- tryCatch(target_repo_spec(ask = FALSE), error = function(e) NULL)
  nm <- if (is_pkg) "Package" else "Project"

  args <- switch(
    fmt,
    Rmd = list(Rmd = TRUE, needs_render = TRUE),
    md = list(needs_render = FALSE),
    qmd = list(quarto = TRUE, needs_render = TRUE)
  )
  data <- list2(
    !!nm := project_name(),
    on_github = !is.null(repo_spec),
    github_spec = repo_spec,
    !!!args
  )

  new <- use_template(
    if (is_pkg) "package-README" else "project-README",
    glue::glue("README.", fmt),
    data = data,
    ignore = if (fmt %in% c("rmd", "qmd")) is_pkg else FALSE,
    open = open
  )

  if (is_pkg && !data$on_github) {
    msg <- switch(
      fmt,
      rmd = "Update {.path {pth('README.Rmd')}} to include installation instructions.",
      md = "Update {.path {pth('README.md')}} to include installation instructions.",
      qmd = "Update {.path {pth('README.qmd')}} to include installation instructions."
    )
    ui_bullets(c("_" = msg))
  }

  if (fmt %in% c("rmd", "qmd") && uses_git()) {
    if (!new) {
      return(invisible(FALSE))
    }

    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh")
    )
    invisible(TRUE)
  } else {
    invisible(new)
  }
}
