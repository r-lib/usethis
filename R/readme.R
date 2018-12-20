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
#' @param use_hook Use pre commit Git hook to enforce README.Rmd and README.md
#'   to be in sync or not. Defaults to NULL which will result in asking user
#'   in interactive session and simple not set the hook in non-interactive
#'   session.
#' @seealso The [important files
#'   section](http://r-pkgs.had.co.nz/release.html#important-files) of [R
#'   Packages](http://r-pkgs.had.co.nz).
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
use_readme_rmd <- function(open = interactive(), use_hook = NULL) {
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
    ignore = TRUE,
    open = open
  )
  if (!new) return(invisible(FALSE))

  if (uses_git()) {
    if ( interactive() & is.null(use_hook) ){
      use_hook <-
        utils::menu(
          choices = c("yes", "no"),
          title = "Do you want to use Git pre commit hooks enforcing README.Rmd and README.md to keep in sync?"
        )
      use_hook <- use_hook == 1
    } else if( !is.null(use_hook) ){
      # do nothing, just use whatever was set in use_hook
    } else {
      use_hook <- FALSE
    }

    if ( use_hook ) {
      use_git_hook(
        "pre-commit",
        render_template("readme-rmd-pre-commit.sh")
      )
      message("Pre commit Git hook installed.")
    }else{
      # do nothing
    }
  }

  invisible(TRUE)
}

#' @export
#' @rdname use_readme_rmd
use_readme_md <- function(open = interactive()) {
  use_template(
    if (is_package()) "package-README" else "project-README",
    "README.md",
    data = project_data(),
    open = open
  )
}
