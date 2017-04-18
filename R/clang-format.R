#' Use clang-format
#'
#' Creates \code{src/.clang-format} and adds a before_install step to
#' `.travis.yml` to check the format is followed.
#'
#' @inheritParams use_template
#' @export
use_clang_format <- function(base_path = ".") {
  if (!uses_travis(base_path)) {
    stop("You must use_travis() first", call. = FALSE)
  }

  use_directory(
    "travis",
    ignore = TRUE,
    base_path = base_path)


  use_template(
    "check_format.sh",
    file.path("travis", "check_format.sh"),
    ignore = TRUE,
    base_path = base_path)
  Sys.chmod(file.path("travis", "check_format.sh"), "0744")

  use_template(
    "clang-format",
    file.path("src", ".clang-format"),
    ignore = TRUE,
    base_path = base_path)

  message("Next run: `travis/check_format.sh` and commit the result")
  message("Then:")
  message("* Add to `.travis.yml`:\n",
    "addons:\n",
    "  apt:\n",
    "    packages:\n",
    "    - clang-format-3.4\n",
    "before_install: travis/check_format.sh\n")
}
