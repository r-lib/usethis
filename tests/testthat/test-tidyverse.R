test_that("use_tidy_description() alphabetises dependencies and remotes", {
  pkg <- create_local_package()
  use_package("usethis")
  use_package("desc")
  use_package("withr", "Suggests")
  use_package("gh", "Suggests")
  desc::desc_set_remotes(c("r-lib/styler", "jimhester/lintr"))
  use_tidy_description()
  desc <- read_utf8(proj_path("DESCRIPTION"))
  expect_gt(grep("usethis", desc), grep("desc", desc))
  expect_gt(grep("withr", desc), grep("gh", desc))
  expect_gt(grep("r\\-lib\\/styler", desc), grep("jimhester\\/lintr", desc))
})

test_that("use_tidy_dependencies() isn't overly informative", {
  skip_if_offline("github.com")

  create_local_package()
  use_package_doc(open = FALSE)
  withr::local_options(usethis.quiet = FALSE, cli.width = Inf)

  expect_snapshot(
    use_tidy_dependencies(),
    transform = scrub_testpkg
  )
})

test_that("use_tidy_GITHUB-STUFF() adds and Rbuildignores files", {
  local_interactive(FALSE)
  local_target_repo_spec("OWNER/REPO")

  create_local_package()
  use_git()
  use_tidy_contributing()
  use_tidy_support()
  use_tidy_issue_template()
  use_tidy_coc()
  expect_proj_file(".github/CONTRIBUTING.md")
  expect_proj_file(".github/ISSUE_TEMPLATE/issue_template.md")
  expect_proj_file(".github/SUPPORT.md")
  expect_proj_file(".github/CODE_OF_CONDUCT.md")
  expect_true(is_build_ignored("^\\.github$"))
})

test_that("use_tidy_github() adds and Rbuildignores files", {
  local_interactive(FALSE)
  local_target_repo_spec("OWNER/REPO")

  create_local_package()
  use_git()
  use_tidy_github()
  expect_proj_file(".github/CONTRIBUTING.md")
  expect_proj_file(".github/ISSUE_TEMPLATE/issue_template.md")
  expect_proj_file(".github/SUPPORT.md")
  expect_proj_file(".github/CODE_OF_CONDUCT.md")
  expect_true(is_build_ignored("^\\.github$"))
})
