test_that("use_logo() doesn't error", {
  skip_if_not_installed("magick")
  skip_on_os("solaris")

  create_local_package()
  img <- magick::image_write(magick::image_read("logo:"), "logo.png")
  expect_error_free(use_logo("logo.png"))
})
