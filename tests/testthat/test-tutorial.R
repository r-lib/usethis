test_that("use_tutorial() checks its inputs", {
  skip_if_not_installed("rmarkdown")

  create_local_package()
  expect_snapshot(use_tutorial(), error = TRUE)
  expect_snapshot(use_tutorial(name = "tutorial-file"), error = TRUE)
})

test_that("use_tutorial() creates a tutorial", {
  skip_if_not_installed("rmarkdown")

  create_local_package()
  local_check_installed()

  use_tutorial(name = "aaa", title = "bbb")

  tute_file <- path("inst", "tutorials", "aaa", "aaa", ext = "Rmd")
  expect_proj_file(tute_file)
  expect_equal(rmarkdown::yaml_front_matter(tute_file)$title, "bbb")
})
