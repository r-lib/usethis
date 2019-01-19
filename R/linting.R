#' Use code linting
#'
#' `use_lintr()` Adds support for code linting using the `lintr` package in one of three ways:
#' local interactive linting only, non-failing (post-build) Travis CI linting, or failing local and Travis CI `testthat` unit test.
#'
#' @param type Options are \code{local}, \code{travis} or \code{test}.
#' @export
use_lintr <- function(type = c("local", "travis", "test")){
  type <- match.arg(type)

  if(type == "test"){
    dir.create("inst", showWarnings = FALSE)
    .lintr <- "inst/.lintr"
  } else {
    .lintr <- ".lintr"
  }

  sink(.lintr)
  cat(paste0("linters: with_defaults(\n  ", "line_length_linter(80))\n"))
  sink()

  if(type == "test" && !file.exists(".lintr")) file.symlink("inst/.lintr", ".lintr")
  use_build_ignore(".lintr")
  if(type == "test"){
    use_build_ignore("inst/.lintr")
    sink("tests/testthat/test-lintr.R")
    cat(paste0("if (requireNamespace(\"lintr\", quietly = TRUE)) {\n  ",
               "context(\"lints\")\n  ",
               "test_that(\"Package Style\", {\n    ",
               "lintr::expect_lint_free()\n  ",
               "})\n", "}\n"))
    sink()
    ui_todo("Code linting set up as a unit test. Edit {ui_path('inst/.lintr')} as needed.")
  } else if(type == "travis"){
    ui_todo("Insert the following code in {ui_path('.travis.yml')}")
    ui_code_block(
      "
      after_success:
      - R CMD INSTALL $PKG_TARBALL
      - Rscript -e 'lintr::lint_package()'
      "
    )
    ui_todo("Code linting set up for Travis CI. Edit {ui_path('inst/.lintr')} as needed.")
  } else {
    ui_todo("Code linting set up for interactive use. Edit {ui_path('.lintr')} as needed.")
  }
  use_package("lintr", "suggests")
}
