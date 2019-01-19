context("test-course")

test_that("normalize_url adds http(s) or leaves unchanged", {
  url <- "bit.ly/usethis-shortlink-example"
  expect_equal(normalize_url(url), paste0("https://", url))
  expect_equal(normalize_url(paste0("https://", url)), paste0("https://", url))
  expect_equal(normalize_url(paste0("http://", url)), paste0("http://", url))
})
