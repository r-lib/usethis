test_that("use_package() won't facilitate dependency on tidyverse", {
  create_local_package()
  expect_usethis_error(use_package("tidyverse"), "rarely a good idea")
})


# use_dev_package() -----------------------------------------------------------

test_that("package_remote() works for an installed package with github URL", {
  expect_equal(package_remote("fs"), "r-lib/fs")
})

test_that("package_remote() works for package installed from github or gitlab", {
  d <- desc::desc(text = c(
    "Package: test",
    "RemoteType: github",
    "RemoteUsername: OWNER",
    "RemoteRepo: test"
  ))
  with_mock(
    `desc::desc` = function(package) d,
    expect_equal(package_remote(d), "OWNER/test")
  )

  d$set(RemoteType = "gitlab")
  with_mock(
    `desc::desc` = function(package) d,
    expect_equal(package_remote(d), "gitlab::OWNER/test")
  )
})

test_that("package_remote() errors if no remote and no github URL", {
  d <- desc::desc(text = c("Package: test"))
  with_mock(
    `desc::desc` = function(package) d,
    expect_usethis_error(package_remote("nope"), "Cannot determine remote")
  )
})
