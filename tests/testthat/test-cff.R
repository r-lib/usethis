test_that("use_cff() creates promised file", {
  create_local_package()
  use_cff()
  expect_proj_file("CITATION.cff")
})
