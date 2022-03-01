#' @keywords internal
#' @import fs
#' @import rlang
"_PACKAGE"

## usethis namespace: start
#' @importFrom glue glue glue_collapse glue_data
#' @importFrom lifecycle deprecated
#' @importFrom purrr map map_chr map_lgl map_int
## usethis namespace: end
NULL

release_bullets <- function() {
  c(
    "Check that `use_code_of_conduct()` is shipping the latest version of the Contributor Covenant (<https://www.contributor-covenant.org>)."
  )
}
