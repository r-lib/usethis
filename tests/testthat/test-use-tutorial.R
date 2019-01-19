context("test-use-tutorial")

test_that("use_tutorial() requires a `name`", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  expect_error(use_tutorial(), "no default")
})

test_that("use_tutorial() requires a `title`", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  expect_error(use_tutorial(name = "tutorial-file"), "no default")
})

test_that("use_tutorial() creates a tutorials folder", {
  scoped_temporary_package()
  use_tutorial("tutorial-file", "Tutorial Title")
  expect_proj_dir(path("inst", "tutorials"))
})

test_that("use_tutorial() creates a tutorial", {
  scoped_temporary_package()
  file_name <- "tutorial-file"

  use_tutorial(file_name, "Tutorial Title")
  expect_proj_file(path("inst", "tutorials", file_name, ext = "Rmd"))
})

test_that("use_tutorial() creates a title in the tutorial's YAML front matter", {
  scoped_temporary_package()
  title <- "Tutorial Title"

  use_tutorial("tutorial-file", title)
  expect_equal(title, rmarkdown::yaml_front_matter(
    path("inst", "tutorials", "tutorial-file", ext = "Rmd")
  )$title)
})
