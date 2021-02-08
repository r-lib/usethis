#' Create a vignette or article
#'
#' Creates a new vignette or article in `vignettes/`. Articles are a special
#' type of vignette that appear on pkgdown websites, but are not included
#' in the package itself (because they are added to `.Rbuildignore`
#' automatically).
#'
#' @section General setup:
#' * Adds needed packages to `DESCRIPTION`.
#' * Adds `inst/doc` to `.gitignore` so built vignettes aren't tracked.
#' * Adds `vignettes/*.html` and `vignettes/*.R` to `.gitignore` so
#'   you never accidentally track rendered vignettes.
#' @param name Base for file name to use for new vignette. Should consist only
#'   of numbers, letters, `_` and `-`. Lower case is recommended.
#' @param title The title of the vignette.
#' @seealso The [vignettes chapter](https://r-pkgs.org/vignettes.html) of
#'   [R Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_vignette("how-to-do-stuff", "How to do stuff")
#' }
use_vignette <- function(name, title = name) {
  check_is_package("use_vignette()")
  check_vignette_name(name)

  use_dependency("knitr", "Suggests")
  use_description_field("VignetteBuilder", "knitr", overwrite = TRUE)
  use_git_ignore("inst/doc")

  use_vignette_template("vignette.Rmd", name, title)

  invisible()
}

#' @export
#' @rdname use_vignette
use_article <- function(name, title = name) {
  check_is_package("use_article()")

  use_vignette_template("article.Rmd", name, title, subdir = "articles")
  use_build_ignore("vignettes/articles")

  invisible()
}

use_vignette_template <- function(template, name, title, subdir = NULL) {
  stopifnot(is_string(name))
  stopifnot(is_string(title))

  use_directory("vignettes")
  if (!is.null(subdir)) {
    use_directory(path("vignettes", subdir))
  }
  use_git_ignore(c("*.html", "*.R"), directory = "vignettes")
  use_dependency("rmarkdown", "Suggests")

  if (!is.null(subdir)) {
    path <- path("vignettes", subdir, asciify(name), ext = "Rmd")
  } else {
    path <- path("vignettes", asciify(name), ext = "Rmd")
  }


  data <- list(
    Package = project_name(),
    vignette_title = title,
    braced_vignette_title = glue("{{{title}}}")
  )

  use_template(template,
    save_as = path,
    data = data,
    open = TRUE
  )

  path
}

check_vignette_name <- function(name) {
  if (!valid_vignette_name(name)) {
    ui_stop(c(
      "{ui_value(name)} is not a valid filename for a vignette. It must:",
      "* Start with a letter.",
      "* Contain only letters, numbers, '_', and '-'."
    ))
  }
}

# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-package-vignettes
# "To ensure that they can be accessed from a browser (as an HTML index is
# provided), the file names should start with an ASCII letter and be comprised
# entirely of ASCII letters or digits or hyphen or underscore."
valid_vignette_name <- function(x) {
  grepl("^[[:alpha:]][[:alnum:]_-]*$", x)
}
