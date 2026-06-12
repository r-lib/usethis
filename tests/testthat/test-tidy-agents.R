test_that("use_tidy_agents() creates expected files", {
  create_local_package()

  use_tidy_agents()

  expect_proj_file("AGENTS.md")
  expect_proj_file(".claude", "CLAUDE.md")

  expect_identical(
    read_utf8(proj_path(".claude", "CLAUDE.md")),
    "@../AGENTS.md"
  )
  expect_identical(
    read_utf8(proj_path("AGENTS.md")),
    read_utf8(path_package("usethis", "AGENTS.md"))
  )

  ignore <- read_utf8(proj_path(".Rbuildignore"))
  expect_in(c("^AGENTS\\.md$", "^\\.claude$"), ignore)

  gitignore <- read_utf8(proj_path(".claude", ".gitignore"))
  expect_in("settings.local.json", gitignore)
})

test_that("learn_tidy_skill() prints the requested skill", {
  expect_output(learn_tidy_skill("deprecate"), "^# Deprecate functions")
})

test_that("learn_tidy_skill() errors informatively for unknown skill", {
  expect_snapshot(learn_tidy_skill("doesnt-exist"), error = TRUE)
})
