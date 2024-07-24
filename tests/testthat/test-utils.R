test_that("check_is_named_list() works", {
  l <- list(a = "a", b = 2, c = letters)
  expect_identical(l, check_is_named_list(l))

  user_facing_function <- function(somevar) {
    check_is_named_list(somevar)
  }

  expect_snapshot(error = TRUE, user_facing_function(NULL))
  expect_snapshot(error = TRUE, user_facing_function(c(a = "a", b = "b")))
  expect_snapshot(error = TRUE, user_facing_function(list("a", b = 2)))
})

test_that("asciify() substitutes non-ASCII but respects case", {
  expect_identical(asciify("aB!d$F+_h"), "aB-d-F-_h")
})

test_that("path_first_existing() works", {
  create_local_project()

  all_3_files <- proj_path(c("alfa", "bravo", "charlie"))

  expect_null(path_first_existing(all_3_files))

  write_utf8(proj_path("charlie"), "charlie")
  expect_equal(path_first_existing(all_3_files), proj_path("charlie"))

  write_utf8(proj_path("bravo"), "bravo")
  expect_equal(path_first_existing(all_3_files), proj_path("bravo"))
})
