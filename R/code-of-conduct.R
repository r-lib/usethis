#' Add a code of conduct
#'
#' Adds a `CODE_OF_CONDUCT.md` file to the active project and lists in
#' `.Rbuildignore`, in the case of a package. The goal of a code of conduct is
#' to foster an environment of inclusiveness, and to explicitly discourage
#' inappropriate behaviour. The template comes from
#' <http://contributor-covenant.org>, version 1:
#' <http://contributor-covenant.org/version/1/0/0/>.
#'
#' @param path Path of the directory to put `CODE_OF_CONDUCT.md` in, relative to
#'   the active project. Passed along to [use_directory()]. Default is to locate
#'   at top-level, but `.github/` is also common.
#'
#' @export
use_code_of_conduct <- function(path = NULL) {
  if (!is.null(path)) {
    use_directory(path, ignore = is_package())
  }
  save_as <- path_join(c(path, "CODE_OF_CONDUCT.md"))

  use_template(
    "CODE_OF_CONDUCT.md",
    save_as = save_as,
    ignore = is_package() && is.null(path)
  )

  todo("Don't forget to describe the code of conduct in your README:")
  code_block(paste0(
    "Please note that the {value(project_name())} project is released with a ",
    "[Contributor Code of Conduct]({save_as}). ",
    "By contributing to this project, you agree to abide by its terms."
  ))
}
