context("test-course")

test_that("adds http(s) if missing, otherwise leaves unchanged", {
  url <- "some/random/url.zip"
  expect_equal(normalize_url(url), paste0("https://", url))
  expect_equal(normalize_url(paste0("https://", url)), paste0("https://", url))
  expect_equal(normalize_url(paste0("http://", url)), paste0("http://", url))
})

test_that("shortlinks pass through", {
  url1 <- "bit.ly/usethis-shortlink-example"
  url2 <- "rstd.io/usethis-shortlink-example"
  expect_equal(normalize_url(url1), paste0("https://", url1))
  expect_equal(normalize_url(url2), paste0("https://", url2))
  expect_equal(normalize_url(paste0("https://", url1)), paste0("https://", url1))
  expect_equal(normalize_url(paste0("http://", url1)), paste0("http://", url1))
})

test_that("github links get expanded", {
  expect_equal(normalize_url("jennybc/explore-libraries"),
    "https://github.com/jennybc/explore-libraries/archive/master.zip")
})
