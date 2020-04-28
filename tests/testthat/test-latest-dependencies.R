test_that("use_tidy_versions() specifies a version for dependencies", {
  pkg <- create_local_package()
  use_package("usethis")
  use_package("desc")
  use_package("withr", "Suggests")
  use_package("gh", "Suggests")
  use_latest_dependencies()
  desc <- read_utf8(proj_path("DESCRIPTION"))
  desc <- grep("usethis|desc|withr|gh", desc, value = TRUE)
  expect_true(all(grepl("\\(>= [0-9.]+\\)", desc)))
})

test_that("use_tidy_versions() does nothing for a base package", {
  ## if we ever depend on a recommended package, could beef up this test a bit
  pkg <- create_local_package()
  use_package("tools")
  use_package("stats", "Suggests")
  use_latest_dependencies()
  desc <- read_utf8(proj_path("DESCRIPTION"))
  desc <- grep("tools|stats", desc, value = TRUE)
  expect_false(any(grepl("\\(>= [0-9.]+\\)", desc)))
})
