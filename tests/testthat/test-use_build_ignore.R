context("use_build_ignore")

test_that(". escaped around surround by anchors", {
  expect_equal(escape_path("."), "^\\.$")
})
