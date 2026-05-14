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

test_that("uses_roxygen() recognizes the 'RoxygenNote' field", {
  skip_if_not_installed("roxygen2")

  roxy_tempdir <- withr::local_tempdir(pattern = "roxy")
  withr::local_dir(roxy_tempdir)
  path_note <- fs::path(roxy_tempdir, "DESCRIPTION")
  fs::file_create(path_note)

  desc::desc_set(
    Package = "oldtyle",
    "RoxygenNote" = "7.3.3",
    check = TRUE,
    file = path_note
  )

  usethis::local_project()
  expect_identical(desc::desc_get_field("Package"), "oldtyle")
  expect_no_error(usethis:::uses_roxygen())
  expect_true(usethis:::uses_roxygen())
})

test_that("uses_roxygen() recognizes the 'Config/roxygen2/version' field", {
  skip_if_not_installed("roxygen2")

  roxy_tempdir <- withr::local_tempdir(pattern = "roxy")
  withr::local_dir(roxy_tempdir)
  path_config <- fs::path(roxy_tempdir, "DESCRIPTION")
  fs::file_create(path_config)

  desc::desc_set(
    Package = "newstyle",
    `Config/roxygen2/version` = "8.0.0",
    check = TRUE,
    file = path_config
  )

  usethis::local_project(quiet = TRUE)
  expect_identical(desc::desc_get_field("Package"), "newstyle")
  expect_no_error(usethis:::uses_roxygen())
  expect_true(usethis:::uses_roxygen())
})

test_that("uses_roxygen() returns FALSE in absence of roxygen fields", {
  skip_if_not_installed("roxygen2")

  roxy_tempdir <- withr::local_tempdir(pattern = "roxy")
  withr::local_dir(roxy_tempdir)
  path_null <- fs::path(roxy_tempdir, "DESCRIPTION")
  fs::file_create(path_null)

  desc::desc_set(
    Package = "nullstyle",
    check = TRUE,
    file = path_null
  )

  usethis::local_project(quiet = TRUE)
  expect_identical(desc::desc_get_field("Package"), "nullstyle")
  expect_no_error(usethis:::uses_roxygen())
  expect_false(usethis:::uses_roxygen())
})
