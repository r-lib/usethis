#' Use code linting
#'
#' `use_lintr()` Adds support for code linting using the `lintr` package. THere are three linting modes available:
#'
#' * "local": local interactive linting only
#' * "travis": non-failing, post-build linting on Travis CI
#' * "test": testthat unit test
#'
#' @param mode Options are `"local"`, `"travis"`, or `"test"`.
#' @export
use_lintr <- function(mode = c("local", "travis", "test")){
  mode <- match.arg(mode)
  use_package("lintr", "suggests")
  if(mode == "test"){
    create_directory("inst")
    .lintr <- "inst/.lintr"
  } else {
    .lintr <- ".lintr"
  }
  write_over(.lintr, c("linters: with_defaults(", "  line_length_linter(80))"))

  if(mode == "test" && !file.exists(".lintr")) file.symlink("inst/.lintr", ".lintr")
  use_build_ignore(".lintr")
  if(mode =="local"){
    ui_todo("Code linting set up for interactive use. Edit {ui_path('.lintr')} as needed.")
  } else if(mode == "test"){
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
  } else {
    ui_todo("Insert the following code in {ui_path('.travis.yml')}")
    ui_code_block(
      "
      after_success:
      - R CMD INSTALL $PKG_TARBALL
      - Rscript -e 'lintr::lint_package()'
      "
    )
    ui_todo("Code linting set up for Travis CI. Edit {ui_path('inst/.lintr')} as needed.")
  }
}
