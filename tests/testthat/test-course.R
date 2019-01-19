context("test-course")

test_that("adds http(s) if missing, otherwise leaves unchanged", {
  url <- "some/random/url.zip"
  expect_equal(normalize_url(url), paste0("https://", url))
  expect_equal(normalize_url(paste0("https://", url)), paste0("https://", url))
  expect_equal(normalize_url(paste0("http://", url)), paste0("http://", url))
})

test_that("shortlinks pass through", {
  url <- "bit.ly/usethis-shortlink-example"
  expect_equal(normalize_url(url), paste0("https://", url))
  expect_equal(normalize_url(paste0("https://", url)), paste0("https://", url))
  expect_equal(normalize_url(paste0("http://", url)), paste0("http://", url))
})

test_that("github links get expanded", {
  expect_equal(normalize_url("jennybc/explore-libraries"),
    "https://github.com/jennybc/explore-libraries/archive/master.zip")
})
