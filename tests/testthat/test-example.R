test_that("use_example() creates an example file", {
  create_local_package()
  use_example("foo", open = FALSE)
  expect_proj_file("man", "examples", "example-foo.R")
})

test_that("can use use_example() in a project", {
  create_local_project()
  expect_error(use_example("foofy"), NA)
})
