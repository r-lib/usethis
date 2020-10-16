#' Create Makefile
#'
#' `use_make()` adds a basic Makefile to the project root directory.
#'
#' @seealso The [documentation for GNU
#'   Make](https://www.gnu.org/software/make/manual/html_node/).
#' @export
use_make <- function() {
  use_template(
    "Makefile",
    data = list(name = project_name())
  )
  use_build_ignore("Makefile")
}

uses_make <- function(base_path = proj_get()) {
  makefile_path <- proj_path("Makefile")
  file_exists(makefile_path)
}
