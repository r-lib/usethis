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
#' @param type One of `"quarto"` or `"rmarkdown"`
#' @seealso The [vignettes chapter](https://r-pkgs.org/vignettes.html) of
#'   [R Packages](https://r-pkgs.org) and the [Quarto vignettes](https://quarto-dev.github.io/quarto-r/articles/hello.html) reference.
#' @export
#' @examples
#' \dontrun{
#' use_vignette("how-to-do-stuff", "How to do stuff")
#' }
use_vignette <- function(name, title = name, type = c("rmarkdown", "quarto")) {
  check_is_package("use_vignette()")
  check_required(name)
  check_vignette_name(name)
  type <- arg_match(type)

  use_dependency("knitr", "Suggests")

  if (type == "rmarkdown") {
    use_dependency("rmarkdown", "Suggests")
    proj_desc_field_update("VignetteBuilder", "knitr", overwrite = FALSE)
    use_vignette_template("vignette.Rmd", name, title)
  } else if (type == "quarto") {
    proj_desc_field_update("VignetteBuilder", "quarto", overwrite = FALSE)
    use_vignette_template("vignette.qmd", name, title)
    use_build_ignore("vignettes/*_files")
    #use_git_ignore("*_files", "vignettes/")
  }
  use_git_ignore("inst/doc")


  invisible()
}

#' @export
#' @rdname use_vignette
use_article <- function(name, title = name, type = c("rmarkdown", "quarto")) {
  check_is_package("use_article()")

  type <- arg_match(type)
  deps <- proj_deps()

  if (type == "rmarkdown") {
    if (!"rmarkdown" %in% deps$package) {
      proj_desc_field_update("Config/Needs/website", "rmarkdown", append = TRUE)
    }

    use_vignette_template("article.Rmd", name, title, subdir = "articles")
  } else if (type == "quarto") {
    if (!"quarto" %in% deps$package) {
      proj_desc_field_update("Config/Needs/website", "quarto", append = TRUE)
    }

    use_vignette_template("article.qmd", name, title, subdir = "articles")
  }

  use_build_ignore("vignettes/articles")

  invisible()
}

use_vignette_template <- function(template, name, title, subdir = NULL) {
  check_name(template)
  check_name(name)
  check_name(title)
  maybe_name(subdir)

  use_directory("vignettes")
  if (!is.null(subdir)) {
    use_directory(path("vignettes", subdir))
  }

  use_git_ignore(c("*.html", "*.R"), directory = "vignettes")
  # make sure nothing else is caught. (this should be assured as `.` are not allowed.)
  vignette_ext <- path_ext(template)
  arg_match0(vignette_ext, c("qmd", "Rmd"))
  if (vignette_ext == "qmd") {
    # https://quarto-dev.github.io/quarto-r/articles/hello.html
    use_git_ignore("*_files", directory = "vignettes")
  }

  if (is.null(subdir)) {
    path <- path("vignettes", asciify(name), ext = vignette_ext)
  } else {
    path <- path("vignettes", subdir, asciify(name), ext = vignette_ext)
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
    ui_abort(c(
      "{.val {name}} is not a valid filename for a vignette. It must:",
      "Start with a letter.",
      "Contain only letters, numbers, '_', and '-'."
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
