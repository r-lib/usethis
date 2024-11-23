# use_vignette ------------------------------------------------------------

test_that("use_vignette() requires a package", {
  create_local_project()

  expect_usethis_error(use_vignette(), "not an R package")
})

test_that("use_vignette() gives useful errors", {
  create_local_package()

  expect_snapshot(error = TRUE, {
    use_vignette()
    use_vignette("bad name")
  })
})

test_that("use_vignette() does the promised setup, Rmd", {
  create_local_package()

  use_vignette("name", "title")
  expect_proj_file("vignettes/name.Rmd")

  ignores <- read_utf8(proj_path(".gitignore"))
  expect_true("inst/doc" %in% ignores)

  deps <- proj_deps()
  expect_true(
    all(c("knitr", "rmarkdown") %in% deps$package[deps$type == "Suggests"])
  )

  expect_identical(proj_desc()$get_field("VignetteBuilder"), "knitr")
})

test_that("use_vignette() does the promised setup, qmd", {
  create_local_package()
  local_check_installed()

  use_vignette("name.qmd", "title")
  expect_proj_file("vignettes/name.qmd")

  ignores <- read_utf8(proj_path(".gitignore"))
  expect_true("inst/doc" %in% ignores)

  deps <- proj_deps()
  expect_true(
    all(c("knitr", "quarto") %in% deps$package[deps$type == "Suggests"])
  )

  expect_identical(proj_desc()$get_field("VignetteBuilder"), "quarto")
})

test_that("use_vignette() does the promised setup, mix of Rmd and qmd", {
  create_local_package()
  local_check_installed()

  use_vignette("older-vignette", "older Rmd vignette")
  use_vignette("newer-vignette.qmd", "newer qmd vignette")
  expect_proj_file("vignettes/older-vignette.Rmd")
  expect_proj_file("vignettes/newer-vignette.qmd")

  deps <- proj_deps()
  expect_true(
    all(c("knitr", "quarto", "rmarkdown") %in% deps$package[deps$type == "Suggests"])
  )

  vignette_builder <- proj_desc()$get_field("VignetteBuilder")
  expect_match(vignette_builder, "knitr", fixed = TRUE)
  expect_match(vignette_builder, "quarto", fixed = TRUE)
})

# use_article -------------------------------------------------------------
test_that("use_article() does the promised setup, Rmd", {
  create_local_package()
  local_interactive(FALSE)

  # Let's have another package already in Config/Needs/website
  proj_desc_field_update("Config/Needs/website", "somepackage")
  use_article("name", "title")

  expect_proj_file("vignettes/articles/name.Rmd")

  expect_setequal(
    proj_desc()$get_list("Config/Needs/website"),
    c("rmarkdown", "somepackage")
  )
})

# Note that qmd articles seem to cause problems for build_site() rn
# https://github.com/r-lib/pkgdown/issues/2821
test_that("use_article() does the promised setup, qmd", {
  create_local_package()
  local_check_installed()
  local_interactive(FALSE)

  # Let's have another package already in Config/Needs/website
  proj_desc_field_update("Config/Needs/website", "somepackage")
  use_article("name.qmd", "title")

  expect_proj_file("vignettes/articles/name.qmd")

  expect_setequal(
    proj_desc()$get_list("Config/Needs/website"),
    c("quarto", "somepackage")
  )
})

# helpers -----------------------------------------------------------------

test_that("valid_vignette_name() works", {
  expect_true(valid_vignette_name("perfectly-valid-name"))
  expect_false(valid_vignette_name("01-test"))
  expect_false(valid_vignette_name("test.1"))
})

test_that("we error informatively for bad vignette extension", {
  expect_snapshot(
    error = TRUE,
    check_vignette_extension("Rnw")
  )
})
