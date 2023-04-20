test_that(". escaped around surround by anchors", {
  expect_equal(escape_path("."), "^\\.$")
})

test_that("strip trailing /", {
  expect_equal(escape_path("./"), "^\\.$")
})
