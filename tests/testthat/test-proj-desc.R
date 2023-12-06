test_that("proj_desc_field_update() only messages when adding", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot({
    proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
    proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
    proj_desc_field_update("Config/Needs/foofy", "bravo", append = TRUE)
  })
  expect_equal(proj_desc()$get_list("Config/Needs/foofy"), c("alfa", "bravo"))
})

test_that("proj_desc_field_update() works with multiple values", {
  create_local_package()
  # Add something to begin with
  proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot({
    proj_desc_field_update("Config/Needs/foofy", c("alfa", "bravo"),
                           append = TRUE)
  })
  expect_equal(proj_desc()$get_list("Config/Needs/foofy"), c("alfa", "bravo"))
})
