context("use_logo")

test_that("use_logo() doesn't error", {
  skip_if_not_installed("magick")
  pkg <- scoped_temporary_package()
  img <- magick::image_write(magick::image_read("logo:"), "logo.png")
  on.exit(file_delete("logo.png"))

  expect_error_free(use_logo("logo.png"))
})

test_that("use_logo() does nothing if badge seems to pre-exist", {
  pkg <- scoped_temporary_package()
  img_link <- "<img src=\"man/figures/logo.png\" align=\"right\" />"
  writeLines(img_link, proj_path("README.md"))
  expect_false(use_logo("logo.png"))
})
