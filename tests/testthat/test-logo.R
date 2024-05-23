test_that("use_logo() doesn't error with no README", {
  skip_if_not_installed("magick")
  skip_on_os("solaris")

  create_local_package()
  img <- magick::image_write(magick::image_read("logo:"), "logo.png")
  expect_no_error(use_logo("logo.png"))
})

test_that("use_logo() shows a clickable path with README", {
  skip_if_not_installed("magick")
  skip_on_os("solaris")

  create_local_package()
  use_readme_md()
  img <- magick::image_write(magick::image_read("logo:"), "logo.png")
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_logo("logo.png"),  transform = scrub_testpkg)
})

test_that("use_logo() nudges towards adding favicons", {
  skip_if_not_installed("magick")
  skip_if_not_installed("pkgdown")
  skip_on_os("solaris")
  create_local_package()
  use_pkgdown()
  img <- magick::image_write(magick::image_read("logo:"), "logo.png")
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_logo("logo.png"),  transform = scrub_testpkg)
})
