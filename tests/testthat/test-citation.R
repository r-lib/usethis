test_that("use_citation() creates promised file", {
  create_local_package()
  use_citation()
  expect_proj_file("inst", "CITATION")
})
