context("utils")

test_that("check_is_dir() doesn't give false positive for trailing slash", {
  pwd <- sub("/$", "", getwd())
  expect_error_free(check_is_dir(paste0(pwd, "/")))
})
