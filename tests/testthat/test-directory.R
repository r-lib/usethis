test_that("create_directory() doesn't bother a pre-existing target dir", {
  tmp <- file_temp()
  dir_create(tmp)
  expect_true(is_dir(tmp))
  expect_error_free(create_directory(tmp))
  expect_true(is_dir(tmp))
})

test_that("create_directory() creates a directory", {
  tmp <- file_temp("yes")
  create_directory(tmp)
  expect_true(is_dir(tmp))
})

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
