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
#' @export
#' @examples
#' \dontrun{
#' # Examples not run, due to dependency on devtools
#' library(usethis)
#' pkgroot <- tempfile("testpkg")
#' devtools::create(pkgroot)
#'
#' # Workflow 1: add data first, then create README
#' # 1. Add the datasets
#' use_data(cars, base_path = pkgroot)
#' # 2. Install the package
#' devtools::install(pkgroot)
#' # 3. Check that the datasets are correctly present
#' list_datasets(basename(pkgroot))
#' # 4. Create the README
#' use_readme_rmd(pkgroot)
#' # or
#' use_readme_md(pkgroot)
#'
#' # Workflow 2: create README first, then add data
#' # 1. Create the README
#' use_readme_rmd(pkgroot)
#' # or
#' use_readme_md(pkgroot)
#' # 2. Add the datasets
#' use_data(cars, base_path = pkgroot)
#' # 3. Install the package
#' devtools::install(pkgroot)
#' # 4. Check that the datasets are correctly present
#' list_datasets(basename(pkgroot))
#' # 5. Update the README
#' use_data_list_in_readme_rmd(pkgroot)
#' # or
#' use_data_list_in_readme_md(pkgroot)
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
    use_data_list_in_readme_rmd(base_path, warn_if_no_data = FALSE)
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
    use_data_list_in_readme_md(base_path, warn_if_no_data = FALSE)
  }
}

#' @rdname use_readme_rmd
#' @export
use_data_list_in_readme_rmd <- function(base_path = ".") {
  use_data_list_in_readme("Rmd", base_path, warn_if_no_data = TRUE)
}

#' @rdname use_readme_rmd
#' @export
use_data_list_in_readme_md <- function(base_path = ".") {
  use_data_list_in_readme("md", base_path, warn_if_no_data = TRUE)
}

use_data_list_in_readme <- function(type = c("Rmd", "md"), base_path = ".", warn_if_no_data = TRUE) {
  type <- match.arg(type)
  if (!uses_data(base_path)) {
    if (warn_if_no_data) {
      warning(
        "The package has no data dir. Add datasets using use_data().",
        call. = FALSE
      )
    }
    return()
  }
  data <- package_data(base_path)
  if (!is_installed(data$Package)) {
    if (warn_if_no_data) {
      warning(
        "The package has not been installed; try building and reloading first.",
        call. = FALSE
      )
    }
    return()
  }

  if (type == "md") {
    data$datasets <- paste(
      knitr::kable(list_datasets(data$Package)),
      collapse = "\n")
  } else { # type == "Rmd"
    data$Rmd <- TRUE
  }

  template_contents <- render_template("omni-README-datasets", data)
  write_append(base_path, paste0("README.", type), template_contents)
}
