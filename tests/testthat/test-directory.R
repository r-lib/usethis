test_that("create_directory() doesn't bother a pre-existing target dir", {
  tmp <- file_temp()
  dir_create(tmp)
  expect_true(is_dir(tmp))
  expect_no_error(create_directory(tmp))
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
  expect_no_error(check_path_is_directory(paste0(pwd, "/")))
})

test_that("symlink to directory is directory", {
  base <- dir_create(file_temp())
  base_a <- dir_create(path(base, "a"))
  base_b <- link_create(base_a, path(base, "b"))

  expect_no_error(check_path_is_directory(base_b))
})

# https://github.com/r-lib/usethis/issues/2069
test_that("relative symlink to directory is directory", {
  base_dir <- withr::local_tempdir()
  sub_dir <- dir_create(path(base_dir, "sub_dir"))
  withr::with_dir(
    base_dir,
    link_create("sub_dir", "relative_link_to_sub_dir", symbolic = !is_windows())
  )

  relative_linky_path <- path(base_dir, "relative_link_to_sub_dir")
  expect_no_error(check_path_is_directory(relative_linky_path))
})
