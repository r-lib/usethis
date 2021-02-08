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

  deps <- desc::desc_get_deps(proj_get())
  expect_true(
    all(c("knitr", "rmarkdown") %in% deps$package[deps$type == "Suggests"])
  )

  expect_identical(
    desc::desc_get_or_fail("VignetteBuilder", proj_get()),
    c(VignetteBuilder = "knitr")
  )
})

# use_article -------------------------------------------------------------

test_that("use_article goes in article subdirectory", {
  create_local_package()

  use_article("test")
  expect_proj_file("vignettes/articles/test.Rmd")
})

# helpers -----------------------------------------------------------------

test_that("valid_vignette_name() works", {
  expect_true(valid_vignette_name("perfectly-valid-name"))
  expect_false(valid_vignette_name("01-test"))
  expect_false(valid_vignette_name("test.1"))
})
