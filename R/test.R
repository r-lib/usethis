#' Sets up overall testing infrastructure
#'
#' Creates `tests/testthat/`, `tests/testthat.R`, and adds the testthat package
#' to the Suggests field. Learn more in <https://r-pkgs.org/tests.html>
#'
#' @param edition testthat edition to use. Defaults to the latest edition, i.e.
#'   the major version number of the currently installed testthat.
#' @param parallel Should tests be run in parallel? This feature appeared in
#'   testthat 3.0.0; see <https://testthat.r-lib.org/articles/parallel.html> for
#'   details and caveats.
#' @seealso [use_test()] to create individual test files
#' @export
#' @examples
#' \dontrun{
#' use_testthat()
#'
#' use_test()
#'
#' use_test("something-management")
#' }
use_testthat <- function(edition = NULL, parallel = FALSE) {
  use_testthat_impl(edition, parallel = parallel)

  ui_todo(
    "Call {ui_code('use_test()')} to initialize a basic test file and open it \\
    for editing."
  )
}

use_testthat_impl <- function(edition = NULL, parallel = FALSE) {
  check_installed("testthat")
  if (utils::packageVersion("testthat") < "2.1.0") {
    ui_stop("testthat 2.1.0 or greater needed. Please install before re-trying")
  }

  if (is_package()) {
    edition <- check_edition(edition)

    use_dependency("testthat", "Suggests", paste0(edition, ".0.0"))
    use_description_field("Config/testthat/edition", edition, overwrite = TRUE)

    if (parallel) {
      use_description_field("Config/testthat/parallel", "true", overwrite = TRUE)
    } else {
      desc::desc_del("Config/testthat/parallel", file = proj_get())
    }
  } else {
    if (!is.null(edition)) {
      ui_stop("Can't declare testthat edition outside of a package")
    }
  }

  use_directory(path("tests", "testthat"))
  use_template(
    "testthat.R",
    save_as = path("tests", "testthat.R"),
    data = list(name = project_name())
  )
}

check_edition <- function(edition = NULL) {
  version <- utils::packageVersion("testthat")[[1, c(1, 2)]]
  if (version[[2]] == "99") {
    version <- version[[1]] + 1L
  } else {
    version <- version[[1]]
  }

  if (is.null(edition)) {
    version
  } else {
    if (!is.numeric(edition) || length(edition) != 1) {
      ui_stop("`edition` must be a single number")
    }
    if (edition > version) {
      vers <- utils::packageVersion("testthat")
      ui_stop("`edition` ({edition}) not available in installed testthat ({vers})")
    }
    as.integer(edition)
  }
}


uses_testthat <- function(base_path = proj_get()) {
  paths <- c(
    path(base_path, "inst", "tests"),
    path(base_path, "tests", "testthat")
  )

  any(dir_exists(paths))
}
