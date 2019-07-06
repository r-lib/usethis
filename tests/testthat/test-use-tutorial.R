context("test-use-tutorial")

test_that("use_tutorial() checks its inputs", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  expect_error(use_tutorial(), "no default")
  expect_error(use_tutorial(name = "tutorial-file"), "no default")
})

test_that("use_tutorial() creates a tutorial", {
  with_mock(
    ## need to pass the check re: whether learnr is installed
    `usethis:::is_installed` = function(pkg) TRUE, {
      scoped_temporary_package()
      use_tutorial(name = "aaa", title = "bbb")
      tute_file <- path("inst", "tutorials", "aaa", ext = "Rmd")
      expect_proj_file(tute_file)
      expect_equal(rmarkdown::yaml_front_matter(tute_file)$title, "bbb")
    }
  )
})
