test_that("trailing slash behaviour of ui_path()", {
  # target doesn't exist so no empirical evidence that it's a directory
  expect_match(ui_path("abc"), "abc'$")

  # path suggests it's a directory
  expect_match(ui_path("abc/"), "abc/'$")
  expect_match(ui_path("abc//"), "abc/'$")

  # path is known to be a directory
  tmpdir <- fs::file_temp(pattern = "ui_path")
  on.exit(fs::dir_delete(tmpdir))
  fs::dir_create(tmpdir)

  expect_match(ui_path(tmpdir), "/'$")
  expect_match(ui_path(paste0(tmpdir, "/")), "[^/]/'$")
  expect_match(ui_path(paste0(tmpdir, "//")), "[^/]/'$")
})
