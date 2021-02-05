test_that("use_pkgdown() requires a package", {
  create_local_project()
  expect_usethis_error(use_pkgdown(), "not an R package")
})

test_that("use_pkgdown() creates and ignores the promised file/dir", {
  create_local_package()
  local_interactive(FALSE)
  with_mock(
    check_installed = function(pkg) TRUE,
    use_pkgdown()
  )
  expect_true(uses_pkgdown())
  expect_true(is_build_ignored("^_pkgdown\\.yml$"))
  expect_true(is_build_ignored("^docs$"))
})

# pkgdown helpers ----
test_that("pkgdown helpers behave in the absence of pkgdown", {
  create_local_package()
  expect_null(pkgdown_config_path())
  expect_false(uses_pkgdown())
  expect_equal(pkgdown_config_meta(), list())
  expect_null(pkgdown_url())
})

test_that("pkgdown_config_meta() returns a list", {
  create_local_package()
  local_interactive(FALSE)
  with_mock(
    check_installed = function(pkg) TRUE,
    use_pkgdown()
  )
  expect_equal(pkgdown_config_meta(), list())
  writeLines(c("home:", "  strip_header: true"), pkgdown_config_path())
  expect_equal(
    pkgdown_config_meta(),
    list(home = list(strip_header = TRUE))
  )
})

test_that("pkgdown_url() returns correct data, warns if pedantic", {
  create_local_package()
  local_interactive(FALSE)
  with_mock(
    check_installed = function(pkg) TRUE,
    use_pkgdown()
  )

  # empty config
  expect_null(pkgdown_url())
  expect_silent(pkgdown_url())
  expect_warning(pkgdown_url(pedantic = TRUE), "url")

  # nonempty config, but no url
  writeLines(c("home:", "  strip_header: true"), pkgdown_config_path())
  expect_null(pkgdown_url())
  expect_silent(pkgdown_url())
  expect_warning(pkgdown_url(pedantic = TRUE), "url")

  # config has url
  writeLines("url: https://usethis.r-lib.org", pkgdown_config_path())
  expect_equal(pkgdown_url(), "https://usethis.r-lib.org")

  # config has url with trailing slash
  writeLines("url: https://usethis.r-lib.org/", pkgdown_config_path())
  expect_equal(pkgdown_url(), "https://usethis.r-lib.org")
})
