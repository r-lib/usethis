test_that("block_append() only writes unique lines", {

  path <- withr::local_tempfile()
  writeLines(block_create(), path)

  block_append("---", c("x", "y"), path)
  block_append("---", c("y", "x"), path)
  expect_equal(block_show(path), c("x", "y"))
})

test_that("block_append() can sort, if requested", {
  path <- withr::local_tempfile()
  writeLines(block_create(), path)

  block_append("---", c("z", "y"), path)
  block_append("---", "x", path, sort = TRUE)
  expect_equal(block_show(path), c("x", "y", "z"))
})
