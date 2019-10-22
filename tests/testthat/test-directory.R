# check_path_is_directory -------------------------------------------------

test_that("no false positive for trailing slash", {
  pwd <- sub("/$", "", getwd())
  expect_error_free(check_path_is_directory(paste0(pwd, "/")))
})

test_that("symlink to directory is directory", {
  base <- dir_create(file_temp())
  base_a <- dir_create(path(base, "a"))
  base_b <- link_create(base_a, path(base, "b"))

  expect_error_free(check_path_is_directory(base_b))
})
