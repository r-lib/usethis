test_that("use_package() won't facilitate dependency on tidyverse", {
  scoped_temporary_package()
  expect_usethis_error(use_package("tidyverse"), "rarely a good idea")
})


# use_dev_package() -----------------------------------------------------------

test_that("use_dev_package() can override over default remote", {
  scoped_temporary_package()

  use_dev_package("usethis", remote = "github::r-lib/usethis")

  desc <- desc::desc(proj_path("DESCRIPTION"))
  expect_equal(desc$get_remotes(), "github::r-lib/usethis")
})


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
  expect_error(package_remote(d), "supported remote")
})


