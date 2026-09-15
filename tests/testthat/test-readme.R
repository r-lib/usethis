test_that("use_readme_md() creates README.md", {
  create_local_package()
  use_readme_md()
  expect_proj_file("README.md")
})

test_that("use_readme_rmd() creates README.Rmd", {
  skip_if_not_installed("rmarkdown")

  create_local_package()
  use_readme_rmd()
  expect_proj_file("README.Rmd")
})

test_that("use_readme_rmd() sets up git pre-commit hook if pkg uses git", {
  skip_if_no_git_user()
  skip_if_not_installed("rmarkdown")

  create_local_package()
  use_git()
  use_readme_rmd(open = FALSE)
  expect_proj_file(".git", "hooks", "pre-commit")
})

test_that("use_readme_md() has expected form for a non-GitHub package", {
  skip_if_not_installed("rmarkdown")
  local_interactive(FALSE)

  create_local_package()
  use_readme_md()
  expect_snapshot(writeLines(read_utf8("README.md")), transform = scrub_testpkg)
})

test_that("use_readme_md() has expected form for a GitHub package", {
  skip_if_not_installed("rmarkdown")
  local_interactive(FALSE)
  local_target_repo_spec("OWNER/TESTPKG")

  create_local_package()
  use_readme_md()
  expect_snapshot(writeLines(read_utf8("README.md")), transform = scrub_testpkg)
})

test_that("use_readme_rmd() has expected form for a non-GitHub package", {
  skip_if_not_installed("rmarkdown")
  local_interactive(FALSE)

  create_local_package()
  use_readme_rmd()
  expect_snapshot(
    writeLines(read_utf8("README.Rmd")),
    transform = scrub_testpkg
  )
})

test_that("use_readme_rmd() has expected form for a GitHub package", {
  skip_if_not_installed("rmarkdown")
  local_interactive(FALSE)
  local_target_repo_spec("OWNER/TESTPKG")

  create_local_package()
  use_readme_rmd()
  expect_snapshot(
    writeLines(read_utf8("README.Rmd")),
    transform = scrub_testpkg
  )
})

test_that("use_readme_qmd() creates README.qmd", {
  create_local_package()
  use_readme_qmd()
  expect_proj_file("README.qmd")
})

test_that("use_readme_qmd() sets up git pre-commit hook if pkg uses git", {
  skip_if_no_git_user()

  create_local_package()
  use_git()
  use_readme_qmd(open = FALSE)
  expect_proj_file(".git", "hooks", "pre-commit")
})

test_that("use_readme_qmd() notices a pre-existing README.Rmd", {
  local_interactive(FALSE)

  create_local_package()
  use_readme_rmd()
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_readme_qmd(), transform = scrub_testpkg)
  expect_proj_file("README.qmd")
  expect_proj_file("README.Rmd")
})

test_that("use_readme_qmd() has expected form for a non-GitHub package", {
  local_interactive(FALSE)

  create_local_package()
  use_readme_qmd()
  expect_snapshot(
    writeLines(read_utf8("README.qmd")),
    transform = scrub_testpkg
  )
})

test_that("use_readme_qmd() has expected form for a GitHub package", {
  local_interactive(FALSE)
  local_target_repo_spec("OWNER/TESTPKG")

  create_local_package()
  use_readme_qmd()
  expect_snapshot(
    writeLines(read_utf8("README.qmd")),
    transform = scrub_testpkg
  )
})
