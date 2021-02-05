test_that("use_tutorial() checks its inputs", {
  skip_if_not_installed("rmarkdown")

  create_local_package()
  expect_error(use_tutorial(), "no default")
  expect_error(use_tutorial(name = "tutorial-file"), "no default")
})

test_that("use_tutorial() creates a tutorial", {
  skip_if_not_installed("rmarkdown")

  create_local_package()
  with_mock(
    # pass the check re: whether learnr is installed
    check_installed = function(pkg) TRUE,
    use_tutorial(name = "aaa", title = "bbb")
  )
  tute_file <- path("inst", "tutorials", "aaa", "aaa", ext = "Rmd")
  expect_proj_file(tute_file)
  expect_equal(rmarkdown::yaml_front_matter(tute_file)$title, "bbb")
})
