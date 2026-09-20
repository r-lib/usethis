test_that("use_tidy_agents() creates expected files", {
  create_local_package()

  use_tidy_agents()

  expect_proj_file("AGENTS.md")

  expect_identical(
    read_utf8(proj_path("AGENTS.md")),
    read_utf8(path_package("usethis", "AGENTS.md"))
  )

  ignore <- read_utf8(proj_path(".Rbuildignore"))
  expect_in("^AGENTS\\.md$", ignore)
})

test_that("use_tidy_agents() deletes a pre-existing .claude directory", {
  create_local_package()
  use_git()

  dir_create(proj_path(".claude"))
  write_utf8(proj_path(".claude", "CLAUDE.md"), "@../AGENTS.md")
  write_utf8(proj_path(".claude", "settings.json"), "{}")

  use_tidy_agents()

  expect_false(dir_exists(proj_path(".claude")))
})

test_that("use_tidy_agents() keeps .claude if it contains other files", {
  create_local_package()
  use_git()

  dir_create(proj_path(".claude"))
  write_utf8(proj_path(".claude", "CLAUDE.md"), "@../AGENTS.md")
  write_utf8(proj_path(".claude", "settings.local.json"), "{}")

  use_tidy_agents()

  expect_false(file_exists(proj_path(".claude", "CLAUDE.md")))
  expect_proj_file(".claude", "settings.local.json")
})

test_that("use_tidy_agents() preserves the 'This package' section", {
  create_local_package()
  use_tidy_agents()

  path <- proj_path("AGENTS.md")
  lines <- append(read_utf8(path), c("Always be testing.", ""), after = 2)
  write_utf8(path, lines)

  local_mocked_bindings(can_overwrite = function(path) TRUE)
  use_tidy_agents()

  expect_in(c("## This package", "Always be testing."), read_utf8(path))
})

test_that("learn_tidy_skill() prints the requested skill", {
  expect_output(learn_tidy_skill("deprecate"), "^# Deprecate functions")
})

test_that("learn_tidy_skill() errors informatively without a skill", {
  expect_snapshot(learn_tidy_skill(), error = TRUE)
})

test_that("learn_tidy_skill() errors informatively for unknown skill", {
  expect_snapshot(learn_tidy_skill("doesnt-exist"), error = TRUE)
})
