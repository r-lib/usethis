test_that("use_package() won't facilitate dependency on tidyverse/tidymodels", {
  create_local_package()
  expect_usethis_error(use_package("tidyverse"), "rarely a good idea")
  expect_usethis_error(use_package("tidymodels"), "rarely a good idea")
})

test_that("use_package() guides new packages but not pre-existing ones", {
  create_local_package()
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot({
    use_package("withr")
    use_package("withr")
    use_package("withr", "Suggests")
  })
})

test_that("use_package() handles R versions with aplomb", {
  create_local_package()
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_package("R"), error = TRUE)
  expect_snapshot(use_package("R", type = "Depends"), error = TRUE)
  expect_snapshot(use_package("R", type = "Depends", min_version = "3.6"))
  expect_equal(subset(proj_deps(), package == "R")$version, ">= 3.6")
  with_mock(
    r_version = function() "4.1",
    {
      expect_snapshot(use_package("R", type = "Depends", min_version = TRUE))
    }
  )

  expect_equal(subset(proj_deps(), package == "R")$version, ">= 4.1")
})

test_that("use_package(type = 'Suggests') guidance w/o and w/ rlang", {
  create_local_package()
  withr::local_options(usethis.quiet = FALSE)

  expect_snapshot(use_package("withr", "Suggests"))
  ui_silence(use_package("rlang"))
  expect_snapshot(use_package("purrr", "Suggests"))
})

test_that("use_package() does not fall over on 2nd LinkingTo request", {
  local_edition(3)
  create_local_package()
  local_interactive(FALSE)

  use_dependency("rlang", "LinkingTo")

  withr::local_options(list(usethis.quiet = FALSE))

  expect_snapshot(use_dependency("rlang", "LinkingTo"))
})

# use_dev_package() -----------------------------------------------------------

test_that("use_dev_package() writes a remote", {
  create_local_package()

  with_mock(
    ui_yeah = function(...) TRUE,
    {
      use_dev_package("usethis")
    }
  )
  expect_equal(proj_desc()$get_remotes(), "r-lib/usethis")
})


test_that("use_dev_package() can override over default remote", {
  create_local_package()

  use_dev_package("usethis", remote = "github::r-lib/usethis")

  expect_equal(proj_desc()$get_remotes(), "github::r-lib/usethis")
})

test_that("package_remote() works for an installed package with github URL", {
  d <- desc::desc(text = c(
    "Package: test",
    "URL: https://github.com/OWNER/test"
  ))
  with_mock(
    ui_yeah = function(...) TRUE,
    {
      expect_equal(package_remote(d), "OWNER/test")
    }
  )
})

test_that("package_remote() works for package installed from github or gitlab", {
  d <- desc::desc(text = c(
    "Package: test",
    "RemoteUsername: OWNER",
    "RemoteRepo: test"
  ))

  d$set(RemoteType = "github")
  expect_equal(package_remote(d), "OWNER/test")

  d$set(RemoteType = "gitlab")
  expect_equal(package_remote(d), "gitlab::OWNER/test")
})

test_that("package_remote() errors if no remote and no github URL", {
  d <- desc::desc(text = c("Package: test"))
  expect_usethis_error(package_remote(d), "Cannot determine remote")
})
