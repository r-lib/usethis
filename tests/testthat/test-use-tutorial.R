context("test-use-tutorial")

test_that("use_tutorial() checks its inputs", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  expect_error(use_tutorial(), "no default")
  expect_error(use_tutorial(name = "tutorial-file"), "no default")
})

test_that("use_tutorial() checks the created tutorial", {
  scoped_temporary_package()
  file_name <- "tutorial-file"
  title <- "Tutorial Title"

  use_tutorial("tutorial-file", "Tutorial Title")
  expect_proj_dir(path("inst", "tutorials"))

  use_tutorial(file_name, "Tutorial Title")
  expect_proj_file(path("inst", "tutorials", file_name, ext = "Rmd"))

  use_tutorial("tutorial-file", title)
  expect_equal(title, rmarkdown::yaml_front_matter(
    path("inst", "tutorials", "tutorial-file", ext = "Rmd")
  )$title)
})
