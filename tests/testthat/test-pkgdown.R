test_that("use_pkgdown() requires a package", {
  create_local_project()
  expect_usethis_error(use_pkgdown(), "not an R package")
})

test_that("use_pkgdown() creates and ignores the promised file/dir", {
  create_local_package()
  local_interactive(FALSE)
  local_check_installed()
  local_mocked_bindings(pkgdown_version = function() "1.9000")
  withr::local_options(usethis.quiet = FALSE)

  expect_snapshot(
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
  local_check_installed()
  local_mocked_bindings(pkgdown_version = function() "1.9000")

  use_pkgdown()
  expect_type(pkgdown_config_meta(), "list")

  writeLines(c("home:", "  strip_header: true"), pkgdown_config_path())
  expect_equal(
    pkgdown_config_meta(),
    list(home = list(strip_header = TRUE))
  )
})

test_that("pkgdown_url() returns correct data, warns if pedantic", {
  create_local_package()
  local_interactive(FALSE)
  local_check_installed()
  local_mocked_bindings(pkgdown_version = function() "1.9000")

  use_pkgdown()

  # empty config
  expect_null(pkgdown_url())
  expect_silent(pkgdown_url())
  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot(
    pkgdown_url(pedantic = TRUE)
  )

  # nonempty config, but no url
  writeLines(c("home:", "  strip_header: true"), pkgdown_config_path())
  expect_null(pkgdown_url())
  expect_silent(pkgdown_url())
  expect_snapshot(
    pkgdown_url(pedantic = TRUE)
  )

  # config has url
  writeLines("url: https://usethis.r-lib.org", pkgdown_config_path())
  expect_equal(pkgdown_url(), "https://usethis.r-lib.org")

  # config has url with trailing slash
  writeLines("url: https://malcolmbarrett.github.io/tidysmd/", pkgdown_config_path())
  expect_equal(pkgdown_url(), "https://malcolmbarrett.github.io/tidysmd/")
})

test_that("use_pkgdown() nudges towards use_logo() if the package seems to have a logo", {
  skip_if_not_installed("magick")
  skip_on_os("solaris")

  create_local_package()
  local_interactive(FALSE)
  local_check_installed()
  local_mocked_bindings(pkgdown_version = function() "1.9000")

  img <- magick::image_write(magick::image_read("logo:"), "hex-sticker.svg")
  withr::local_options("usethis.quiet" = FALSE)
  expect_snapshot({
    use_pkgdown()},  transform = scrub_testpkg)
})

test_that("use_pkgdown() nudges towards build_favicons().", {
  skip_on_os("solaris")

  create_local_package()
  local_interactive(FALSE)
  local_check_installed()
  local_mocked_bindings(pkgdown_version = function() "1.9000")
  create_directory("man/figures")
  img <- magick::image_write(magick::image_read("logo:"), path = "man/figures/logo.svg")
  withr::local_options("usethis.quiet" = FALSE)
  expect_snapshot({
    use_pkgdown()},  transform = scrub_testpkg)
})

test_that("tidyverse_url() leaves trailing slash alone, almost always", {
  url <- "https://malcolmbarrett.github.io/tidysmd/"
  out <- tidyverse_url(url, tr = list(repo_name = "REPO", repo_owner = "OWNER"))
  expect_equal(out, url)
})
