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
#' \code{use_data_list_in_readme_rmd} and \code{use_data_list_in_readme_md}
#' append a table to the README listing the datasets contained in the package.
#' @inheritParams use_template
#' @param stop_if_no_data Logical. If \code{TRUE},
#'   \code{use_data_list_in_readme_rmd} and \code{use_data_list_in_readme_md}
#'   will throw an error if the package has no data directory, or the package
#'   has not been installed.
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
use_readme_rmd <- function(base_path = ".") {

  data <- package_data(base_path)
  data$Rmd <- TRUE

  use_template(
    "omni-README",
    "README.Rmd",
    data = data,
    ignore = TRUE,
    open = TRUE,
    base_path = base_path
  )
  if (uses_data(base_path)) {
    use_data_list_in_readme_rmd(base_path, stop_if_no_data = FALSE)
  }
  use_build_ignore("^README-.*\\.png$", escape = FALSE, base_path = base_path)

  if (uses_git(base_path) && !file.exists(base_path, ".git", "hooks", "pre-commit")) {
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
use_readme_md <- function(base_path = ".") {
  use_template(
    "omni-README",
    "README.md",
    data = package_data(base_path),
    open = TRUE,
    base_path = base_path
  )
  if (uses_data(base_path)) {
    use_data_list_in_readme_md(base_path, stop_if_no_data = FALSE)
  }
}

#' @rdname use_readme_rmd
#' @export
use_data_list_in_readme_rmd <- function(base_path = ".", stop_if_no_data = TRUE) {
  use_data_list_in_readme("Rmd", base_path, stop_if_no_data)
}

#' @rdname use_readme_rmd
#' @export
use_data_list_in_readme_md <- function(base_path = ".", stop_if_no_data = TRUE) {
  use_data_list_in_readme("md", base_path, stop_if_no_data)
}

use_data_list_in_readme <- function(type = c("Rmd", "md"), base_path = ".", stop_if_no_data = TRUE) {
  type <- match.arg(type)
  if (!uses_data(base_path)) {
    if (stop_if_no_data) {
      stop("The package has no data dir. Add datasets using use_data().", call. = FALSE)
    }
    return()
  }
  data <- package_data(base_path)
  if (!is_installed(data$Package)) {
    if (stop_if_no_data) {
      stop("The package has not been installed; try building and reloading first.", call. = FALSE)
    }
    return()
  }
  readme_file <- file.path(base_path, paste0("README.", type))
  if (type == "md") {
    data$datasets <- paste(
      knitr::kable(list_datasets(data$Package)),
      collapse = "\n")
  } else { # type == "Rmd"
    data$Rmd <- TRUE
  }

  template_contents <- render_template("omni-README-datasets", data)
  append_to(template_contents, readme_file)
}
