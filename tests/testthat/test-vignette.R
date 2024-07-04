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

test_that("use_vignette() does the promised setup", {
  create_local_package()

  use_vignette("name", "title")
  expect_proj_file("vignettes/name.Rmd")

  ignores <- read_utf8(proj_path(".gitignore"))
  expect_true("inst/doc" %in% ignores)

  deps <- proj_deps()
  expect_contains(
    deps$package[deps$type == "Suggests"],
    c("knitr", "rmarkdown")
  )

  expect_identical(proj_desc()$get_field("VignetteBuilder"), "knitr")
})

test_that("use_vignette() works with Quarto", {
  create_local_package()

  use_vignette("name", "title", type = "quarto")
  expect_proj_file("vignettes/name.qmd")

  ignores <- read_utf8(proj_path(".gitignore"))
  expect_true("inst/doc" %in% ignores)

  deps <- proj_deps()
  expect_contains(
    deps$package[deps$type == "Suggests"],
    "knitr"
  )

  expect_identical(proj_desc()$get_field("VignetteBuilder"), "quarto")
})

# use_article -------------------------------------------------------------

test_that("use_article goes in article subdirectory", {
  create_local_package()

  use_article("test")
  expect_proj_file("vignettes/articles/test.Rmd")
})

test_that("use_article() adds rmarkdown to Config/Needs/website", {
  create_local_package()
  local_interactive(FALSE)

  proj_desc_field_update("Config/Needs/website", "somepackage", append = TRUE)
  use_article("name", "title")

  expect_setequal(
    proj_desc()$get_list("Config/Needs/website"),
    c("rmarkdown", "somepackage")
  )
})

test_that("use_article() adds quarto to Config/Needs/website", {
  create_local_package()
  local_interactive(FALSE)

  proj_desc_field_update("Config/Needs/website", "somepackage", append = TRUE)
  use_article("name", "title", "quarto")

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
