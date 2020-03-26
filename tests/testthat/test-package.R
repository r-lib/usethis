test_that("use_package() won't facilitate dependency on tidyverse", {
  scoped_temporary_package()
  expect_usethis_error(use_package("tidyverse"), "rarely a good idea")
})


# use_dev_package() -----------------------------------------------------------

test_that("package_remote() extracts and generates correct strings", {
  d <- desc::desc(text = c(
    "Package: test",
    "RemoteType: github",
    "RemoteUsername: tidyverse",
    "RemoteRepo: test"
  ))

  expect_equal(package_remote(d), "tidyverse/test")

  d$set(RemoteType = "GitLab")
  expect_equal(package_remote(d), "GitLab::tidyverse/test")

  d$del("RemoteType")
  expect_usethis_error(package_remote(d), "supported remote")
})


