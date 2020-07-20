test_that("use_package() won't facilitate dependency on tidyverse/tidymodels", {
  create_local_package()
  expect_usethis_error(use_package("tidyverse"), "rarely a good idea")
  expect_usethis_error(use_package("tidymodels"), "rarely a good idea")
})


# use_dev_package() -----------------------------------------------------------

test_that("use_dev_package() can override over default remote", {
  create_local_package()

  use_dev_package("usethis", remote = "github::r-lib/usethis")

  desc <- desc::desc(proj_path("DESCRIPTION"))
  expect_equal(desc$get_remotes(), "github::r-lib/usethis")
})

test_that("package_remote() works for an installed package with github URL", {
  d <- desc::desc(text = c(
    "Package: test",
    "URL: https://github.com/OWNER/test"
  ))
  with_mock(
    `desc::desc` = function(package) d,
    ui_yeah = function(...) TRUE,
    expect_equal(package_remote("whatever"), "OWNER/test")
  )
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
    expect_equal(package_remote("whatever"), "OWNER/test")
  )

  d$set(RemoteType = "gitlab")
  with_mock(
    `desc::desc` = function(package) d,
    expect_equal(package_remote("whatever"), "gitlab::OWNER/test")
  )
})

test_that("package_remote() errors if no remote and no github URL", {
  d <- desc::desc(text = c("Package: test"))
  with_mock(
    `desc::desc` = function(package) d,
    expect_usethis_error(package_remote("nope"), "Cannot determine remote")
  )
})
