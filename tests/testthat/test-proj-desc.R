test_that("proj_desc_field_append() only messages when adding", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_snapshot({
    proj_desc_field_append("Config/Needs/foofy", "alfa")
    proj_desc_field_append("Config/Needs/foofy", "alfa")
    proj_desc_field_append("Config/Needs/foofy", "bravo")
  })
  expect_equal(proj_desc()$get_list("Config/Needs/foofy"), c("alfa", "bravo"))
})
