test_that("can detect path from RStudio project file", {
  scoped_temporary_package()
  use_rstudio("unix")
  expect_equal(proj_line_ending(), "\n")

  file_delete(proj_path(paste(paste0(project_name(), ".Rproj"))))
  use_rstudio("windows")
  expect_equal(proj_line_ending(), "\r\n")
})

test_that("correctly detect line encoding", {
  path <- file_temp()

  con <- file(path, open = "wb")
  writeLines(c("a", "b", "c"), con, sep = "\n")
  close(con)
  expect_equal(detect_line_ending(path), "\n")

  con <- file(path, open = "wb")
  writeLines(c("a", "b", "c"), con, sep = "\r\n")
  close(con)
  expect_equal(detect_line_ending(path), "\r\n")
})
