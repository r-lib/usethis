context("test-directory")

test_that("check_is_dir() doesn't give false positive for trailing slash", {
  pwd <- sub("/$", "", getwd())
  expect_error_free(check_path_is_directory(paste0(pwd, "/")))
})

