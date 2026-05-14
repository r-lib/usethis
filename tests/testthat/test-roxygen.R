test_that("use_package_doc() compatible with roxygen_ns_append()", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_snapshot(use_package_doc(), transform = scrub_testpkg)
  expect_snapshot(roxygen_ns_append("test"), transform = scrub_testpkg)
  expect_silent(roxygen_ns_append("test"))
})

test_that("use_roxygen_md() adds DESCRIPTION fields to naive package", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  use_roxygen_md()

  desc <- proj_desc()
  expect_equal(desc$get("Roxygen"), c(Roxygen = "list(markdown = TRUE)"))
  expect_true(desc$has_fields("RoxygenNote"))
  expect_true(uses_roxygen_md())
})

test_that("use_roxygen_md() finds 'markdown = TRUE' in presence of other stuff", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  desc::desc_set(
    Roxygen = 'list(markdown = TRUE, r6 = FALSE, load = "source", roclets = c("collate", "namespace", "rd", "roxyglobals::global_roclet"))'
  )

  local_check_installed()
  expect_no_error(use_roxygen_md())
  expect_true(uses_roxygen_md())
})

test_that("uses_roxygen() recognizes Roxygen fields", {
  skip_if_not_installed("roxygen2")

  path <- withr::local_tempdir(pattern = "roxy")
  desc <- desc::description$new("!new")
  desc$write(file = file.path(path, "DESCRIPTION"))
  local_project(path)

  # Default
  expect_false(uses_roxygen())

  # Old style
  desc2 <- desc$clone()
  desc2$set("RoxygenNote", "7.3.3")
  desc2$write(file = file.path(path, "DESCRIPTION"))
  expect_true(uses_roxygen())

  # New style
  desc3 <- desc$clone()
  desc3$set("Config/roxygen2/version", "8.0.0")
  desc3$write(file = file.path(path, "DESCRIPTION"))
  expect_true(uses_roxygen())
})
