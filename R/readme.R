#' Create README files.
#'
#' Creates skeleton README files with sections for
#' \itemize{
#' \item a high-level description of the package and its goals
#' \item R code to install from GitHub, if GitHub usage detected
#' \item a basic example
#' }
#' Use \code{Rmd} if you want a rich intermingling of code and data. Use
#' \code{md} for a basic README. \code{README.Rmd} will be automatically
#' added to \code{.Rbuildignore}. The resulting README is populated with default
#' YAML frontmatter and R fenced code blocks (\code{md}) or chunks (\code{Rmd}).
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
#' @family infrastructure
use_readme_rmd <- function(pkg = ".") {
  pkg <- as.package(pkg)

  if (uses_github(pkg$path)) {
    pkg$github <- github_info(pkg$path)
  }
  pkg$Rmd <- TRUE

  use_template("omni-README", save_as = "README.Rmd", data = pkg,
               ignore = TRUE, open = TRUE, pkg = pkg)
  use_build_ignore("^README-.*\\.png$", escape = FALSE, pkg = pkg)

  if (uses_git(pkg$path) && !file.exists(pkg$path, ".git", "hooks", "pre-commit")) {
    message("* Adding pre-commit hook")
    use_git_hook("pre-commit", render_template("readme-rmd-pre-commit.sh"),
      pkg = pkg)
  }

  invisible(TRUE)
}

#' @export
#' @rdname use_readme_rmd
use_readme_md <- function(pkg = ".") {
  pkg <- as.package(pkg)
  if (uses_github(pkg$path)) {
    pkg$github <- github_info(pkg$path)
  }

  use_template("omni-README", save_as = "README.md",
               data = pkg, open = TRUE, pkg = pkg)
}
