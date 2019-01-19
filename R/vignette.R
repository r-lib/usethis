#' Create a vignette or article.
#'
#' Creates new vignette/article in `vignettes/`. Article are a special
#' type of vignette that appear on pkgdown websites, but are not included
#' in the package itself (because they are added to `.Rbuildignore`
#' automatically).
#'
#' @section General setup:
#' * Adds needed packages to `DESCRIPTION`.
#' * Adds `inst/doc` to `.gitignore` so built vignettes aren't tracked.
#' * Adds `vignettes/*.html` and `vignettes/*.R` to `.gitignore` so
#'   you never accidental track rendered vignettes.
#' @param name Base for file name to use for new vignette. Should consist only
#'   of numbers, letters, _ and -. I recommend using lower case.
#' @param title The title of the vignette.
#' @seealso The [vignettes chapter](http://r-pkgs.had.co.nz/vignettes.html) of
#'   [R Packages](http://r-pkgs.had.co.nz).
#' @export
#' @examples
#' \dontrun{
#' use_vignette("how-to-do-stuff", "How to do stuff")
#' }
use_vignette <- function(name, title = name) {
  check_is_package("use_vignette()")
  check_filename(name)

  use_dependency("knitr", "Suggests")
  use_description_field("VignetteBuilder", "knitr")
  use_git_ignore("inst/doc")

  use_vignette_template("vignette.Rmd", name, title)
}

#' @export
#' @rdname use_vignette
use_article <- function(name, title = name) {
  check_is_package("use_article()")

  path <- use_vignette_template("article.Rmd", name, title)
  use_build_ignore(path)

  invisible()
}

use_vignette_template <- function(template, name, title) {
  stopifnot(is_string(name))
  stopifnot(is_string(title))

  use_directory("vignettes")
  use_git_ignore(c("*.html", "*.R"), directory = "vignettes")
  use_dependency("rmarkdown", "Suggests")

  path <- path("vignettes", asciify(name), ext = "Rmd")

  data <- project_data()
  data$vignette_title <- title
  data$braced_vignette_title <- glue::glue("{{{title}}}")

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
      "{ui_value(name)} is an invalid vignette name. It should:",
      "* Start with an ASCII letter",
      "* Contain only ASCII letters, numbers, '_', and '-'"
    ))
  }
}

valid_vignette_name <- function(x) {
  grepl("^[[:alpha:]][[:alnum:]\\-_]+$", x)
}
