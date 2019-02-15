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
    create_directory("inst")
    .lintr <- "inst/.lintr"
  } else {
    .lintr <- ".lintr"
  }
  write_over(.lintr, c("linters: with_defaults(", "  line_length_linter(80))"))

  if(type == "test" && !file.exists(".lintr")) file.symlink("inst/.lintr", ".lintr")
  use_build_ignore(".lintr")
  if(type == "test"){
    use_build_ignore("inst/.lintr")
    write_over(
      "tests/testthat/test-lintr.R",
      c("if (requireNamespace(\"lintr\", quietly = TRUE)) {",
        "  context(\"lints\")",
        "  test_that(\"Package Style\", {",
        "    lintr::expect_lint_free()",
        "  })", "}")
    )
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
