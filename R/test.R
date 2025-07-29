#' Sets up overall testing infrastructure
#'
#' Creates `tests/testthat/`, `tests/testthat.R`, and adds the testthat package
#' to the Suggests field. Learn more in <https://r-pkgs.org/testing-basics.html>
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

  ui_bullets(c(
    "_" = "Call {.run usethis::use_test()} to initialize a basic test file and
           open it for editing."
  ))
}

use_testthat_impl <- function(edition = NULL, parallel = FALSE) {
  check_installed("testthat", version = "2.1.0")

  if (is_package()) {
    edition <- check_edition(edition)

    use_dependency("testthat", "Suggests", paste0(edition, ".0.0"))
    proj_desc_field_update(
      "Config/testthat/edition",
      as.character(edition),
      overwrite = TRUE
    )

    if (parallel) {
      proj_desc_field_update(
        "Config/testthat/parallel",
        "true",
        overwrite = TRUE
      )
    } else {
      proj_desc()$del("Config/testthat/parallel")
    }
  } else {
    if (!is.null(edition)) {
      ui_abort("Can't declare {.pkg testthat} edition outside of a package.")
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
  version <- testthat_version()[[1, c(1, 2)]]
  if (version[[2]] == "99") {
    version <- version[[1]] + 1L
  } else {
    version <- version[[1]]
  }

  if (is.null(edition)) {
    version
  } else {
    if (!is.numeric(edition) || length(edition) != 1) {
      ui_abort("{.arg edition} must be a single number.")
    }
    if (edition > version) {
      vers <- testthat_version()
      ui_abort(
        "
        {.var edition} ({edition}) not available in installed verion of
        {.pkg testthat} ({vers})."
      )
    }
    as.integer(edition)
  }
}

# wrapping so we can mock this in tests
testthat_version <- function() {
  utils::packageVersion("testthat")
}

uses_testthat <- function() {
  paths <- proj_path(c(path("inst", "tests"), path("tests", "testthat")))
  any(dir_exists(paths))
}
