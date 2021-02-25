#' Add a code of conduct
#'
#' Adds a `CODE_OF_CONDUCT.md` file to the active project and lists in
#' `.Rbuildignore`, in the case of a package. The goal of a code of conduct is
#' to foster an environment of inclusiveness, and to explicitly discourage
#' inappropriate behaviour. The template comes from
#' <https://www.contributor-covenant.org>, version 2:
#' <https://www.contributor-covenant.org/version/2/0/code_of_conduct/>.
#'
#' If your package is going to CRAN, the link to the CoC in your README must
#' be an absolute link to a rendered website as `CODE_OF_CONDUCT.md` is not
#' included in the package sent to CRAN. `use_code_of_conduct()` will
#' automatically generate this link if (1) you use pkgdown and (2) have set the
#' `url` field in `_pkgdown.yml`; otherwise it will link to a copy of the CoC
#' on <https://www.contributor-covenant.org>.
#'
#' @param contact Contact details for making a code of conduct report.
#'   Usually an email address.
#' @param path Path of the directory to put `CODE_OF_CONDUCT.md` in, relative to
#'   the active project. Passed along to [use_directory()]. Default is to locate
#'   at top-level, but `.github/` is also common.
#'
#' @export
use_code_of_conduct <- function(contact, path = NULL) {
  if (missing(contact)) {
      ui_stop("
        {ui_code('use_code_of_conduct()')} requires contact details in \\
        first argument")
  }

  if (!is.null(path)) {
    use_directory(path, ignore = is_package())
  }
  save_as <- path_join(c(path, "CODE_OF_CONDUCT.md"))

  new <- use_template(
    "CODE_OF_CONDUCT.md",
    save_as = save_as,
    data = list(contact = contact),
    ignore = is_package() && is.null(path)
  )

  href <- pkgdown_url(pedantic = TRUE) %||%
    "https://contributor-covenant.org/version/2/0"
  href <- paste0(href, "/CODE_OF_CONDUCT.html")

  ui_todo("Don't forget to describe the code of conduct in your README:")
  ui_code_block("
    ## Code of Conduct

    Please note that the {project_name()} project is released with a \\
    [Contributor Code of Conduct]({href}). By contributing to this project, \\
    you agree to abide by its terms."
  )

  invisible(new)
}
