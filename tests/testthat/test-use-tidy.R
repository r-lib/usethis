context("tidyverse")

test_that("use_tidy_description() alphabetises dependencies", {
  pkg <- scoped_temporary_package()
  use_package("usethis")
  use_package("desc")
  use_package("withr", "Suggests")
  use_package("gh", "Suggests")
  use_tidy_description()
  desc <- readLines(proj_path("DESCRIPTION"))
  expect_gt(grep("usethis", desc), grep("desc", desc))
  expect_gt(grep("withr", desc), grep("gh", desc))
})

test_that("use_tidy_versions() specifies a version for dependencies", {
  pkg <- scoped_temporary_package()
  use_package("usethis")
  use_package("desc")
  use_package("withr", "Suggests")
  use_package("gh", "Suggests")
  use_tidy_versions()
  desc <- readLines(proj_path("DESCRIPTION"))
  desc <- grep("usethis|desc|withr|gh", desc, value = TRUE)
  expect_true(all(grepl("\\(>= [0-9.]+\\)", desc)))
})

test_that("use_tidy_versions() does nothing for a base package", {
  ## if we ever depend on a recommended package, could beef up this test a bit
  pkg <- scoped_temporary_package()
  use_package("tools")
  use_package("stats", "Suggests")
  use_tidy_versions()
  desc <- readLines(proj_path("DESCRIPTION"))
  desc <- grep("tools|stats", desc, value = TRUE)
  expect_false(any(grepl("\\(>= [0-9.]+\\)", desc)))
})

test_that("use_tidy_eval() inserts the template file and Imports rlang", {
  skip_if_not_installed("roxygen2")

  pkg <- scoped_temporary_package()
  ## fake the use of roxygen; this better in a test than use_roxygen_md()
  use_description_field(name = "RoxygenNote", value = "6.0.1.9000")
  use_tidy_eval()
  expect_match(dir_ls(proj_path("R")), "utils-tidy-eval.R")
  expect_match(desc::desc_get("Imports", pkg), "rlang")
})

test_that("use_tidy_GITHUB-STUFF() adds and Rbuildignores files", {
  with_mock(
    `usethis:::uses_travis` = function(base_path) TRUE,
    `gh::gh_tree_remote` = function(path) list(username = "USER", repo = "REPO"), {
      scoped_temporary_package()
      use_tidy_contributing()
      use_tidy_issue_template()
      use_tidy_support()
      use_tidy_coc()
      expect_proj_file(".github/CONTRIBUTING.md")
      expect_proj_file(".github/ISSUE_TEMPLATE.md")
      expect_proj_file(".github/SUPPORT.md")
      expect_proj_file(".github/CODE_OF_CONDUCT.md")
      expect_true(is_build_ignored("^\\.github$"))
    }
  )
})

test_that("use_tidy_github() adds and Rbuildignores files", {
  with_mock(
    `usethis:::uses_travis` = function(base_path) TRUE,
    `gh::gh_tree_remote` = function(path) list(username = "USER", repo = "REPO"), {
      scoped_temporary_package()
      use_tidy_github()
      expect_proj_file(".github/CONTRIBUTING.md")
      expect_proj_file(".github/ISSUE_TEMPLATE.md")
      expect_proj_file(".github/SUPPORT.md")
      expect_proj_file(".github/CODE_OF_CONDUCT.md")
      expect_true(is_build_ignored("^\\.github$"))
    }
  )
})
