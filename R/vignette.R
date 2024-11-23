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
#' * For `*.qmd`, adds Quarto-related patterns to `.gitignore` and
#'   `.Rbuildignore`.
#' @param name File name to use for new vignette. Should consist only of
#'   numbers, letters, `_` and `-`. Lower case is recommended. Can include the
#'   `".Rmd"` or `".qmd"` file extension, which also dictates whether to place
#'   an R Markdown or Quarto vignette. R Markdown (`".Rmd"`) is the current
#'   default, but it is anticipated that Quarto (`".qmd"`) will become the
#'   default in the future.
#' @param title The title of the vignette. If not provided, a title is generated
#'   from `name`.
#' @seealso
#' * The [vignettes chapter](https://r-pkgs.org/vignettes.html) of
#'   [R Packages](https://r-pkgs.org)
#' * The pkgdown vignette on Quarto:
#'   `vignette("quarto", package = "pkgdown")`
#' * The quarto (as in the R package) vignette on HTML vignettes:
#'   `vignette("hello", package = "quarto")`
#' @export
#' @examples
#' \dontrun{
#' use_vignette("how-to-do-stuff", "How to do stuff")
#' use_vignette("r-markdown-is-classic.Rmd", "R Markdown is classic")
#' use_vignette("quarto-is-cool.qmd", "Quarto is cool")
#' }
use_vignette <- function(name, title = NULL) {
  check_is_package("use_vignette()")
  check_required(name)
  maybe_name(title)

  ext <- get_vignette_extension(name)
  if (ext == "qmd") {
    check_installed("quarto")
    check_installed("pkgdown", version = "2.1.0")
  }

  name <- path_ext_remove(name)
  check_vignette_name(name)
  title <- title %||% name

  use_dependency("knitr", "Suggests")
  use_git_ignore("inst/doc")

  if (tolower(ext) == "rmd") {
    use_dependency("rmarkdown", "Suggests")
    proj_desc_field_update("VignetteBuilder", "knitr", overwrite = TRUE, append = TRUE)
    use_vignette_template("vignette.Rmd", name, title)
  } else {
    use_dependency("quarto", "Suggests")
    proj_desc_field_update("VignetteBuilder", "quarto", overwrite = TRUE, append = TRUE)
    use_vignette_template("vignette.qmd", name, title)
  }

  invisible()
}

#' @export
#' @rdname use_vignette
use_article <- function(name, title = NULL) {
  check_is_package("use_article()")
  check_required(name)
  maybe_name(title)

  ext <- get_vignette_extension(name)
  if (ext == "qmd") {
    check_installed("quarto")
    check_installed("pkgdown", version = "2.1.0")
  }

  name <- path_ext_remove(name)
  title <- title %||% name

  if (tolower(ext) == "rmd") {
    proj_desc_field_update("Config/Needs/website", "rmarkdown", overwrite = TRUE, append = TRUE)
    use_vignette_template("article.Rmd", name, title, subdir = "articles")
  } else {
    # check this dependency stuff
    use_dependency("quarto", "Suggests")
    proj_desc_field_update("Config/Needs/website", "quarto", overwrite = TRUE, append = TRUE)
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

  ext <- get_vignette_extension(template)

  if (is.null(subdir)) {
    target_dir <- "vignettes"
  } else {
    target_dir <- path("vignettes", subdir)
  }

  use_directory(target_dir)

  use_git_ignore(c("*.html", "*.R"), directory = target_dir)
  if (ext == "qmd") {
    use_git_ignore("**/.quarto/")
    use_git_ignore("*_files", target_dir)
    use_build_ignore(path(target_dir, ".quarto"))
    use_build_ignore(path(target_dir, "*_files"))
  }

  path <- path(target_dir, asciify(name), ext = ext)

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

check_vignette_extension <- function(ext) {
  # Quietly accept "rmd" here, tho we'll always write ".Rmd" in such a filepath
  if (! ext %in% c("Rmd", "rmd", "qmd")) {
    valid_exts_cli <- cli::cli_vec(
      c("Rmd", "qmd"),
      style = list("vec-sep2" = " or ")
    )
    ui_abort(c(
      "Unsupported file extension: {.val {ext}}",
      "usethis can only create a vignette or article with one of these
       extensions: {.val {valid_exts_cli}}."
    ))
  }
}

get_vignette_extension <- function(name) {
  ext <- path_ext(name)
  if (nzchar(ext)) {
    check_vignette_extension(ext)
  } else {
    ext <- "Rmd"
  }
  ext
}
