context("use_logo")

test_that("use_logo() doesn't error", {
  skip_if_not_installed("magick")
  pkg <- scoped_temporary_package()
  img <- magick::image_write(magick::image_read("logo:"), "logo.png")
  on.exit(file_delete("logo.png"))

  expect_error_free(use_logo("logo.png"))
})
