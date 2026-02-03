test_that("creates correct default package files", {
  create_local_package()

  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_air())

  # Empty, but should exist
  expect_proj_file("air.toml")

  ignore <- read_utf8(proj_path(".Rbuildignore"))
  expect_in(air_toml_regex(), ignore)
  expect_in(escape_path(".vscode"), ignore)

  settings <- jsonlite::read_json(proj_path(".vscode", "settings.json"))
  expect_true(settings[["[r]"]][["editor.formatOnSave"]])
  expect_identical(
    settings[["[r]"]][["editor.defaultFormatter"]],
    "Posit.air-vscode"
  )
  settings <- jsonlite::read_json(proj_path(".vscode", "extensions.json"))
  recommendations <- settings[["recommendations"]]
  expect_identical(recommendations, list("Posit.air-vscode"))

  # Snapshot exact details to look at indent level and prettyfication
  expect_snapshot(
    writeLines(read_utf8(proj_path(".vscode", "settings.json")))
  )
  expect_snapshot(
    writeLines(read_utf8(proj_path(".vscode", "extensions.json")))
  )
})

test_that("creates correct default project files", {
  create_local_project()

  use_air()

  # Empty, but should exist
  expect_proj_file("air.toml")

  # Does not add to `.Rbuildignore` in projects
  expect_false(file_exists(proj_path(".Rbuildignore")))

  settings <- jsonlite::read_json(proj_path(".vscode", "settings.json"))
  expect_true(settings[["[r]"]][["editor.formatOnSave"]])
  expect_identical(
    settings[["[r]"]][["editor.defaultFormatter"]],
    "Posit.air-vscode"
  )
  settings <- jsonlite::read_json(proj_path(".vscode", "extensions.json"))
  recommendations <- settings[["recommendations"]]
  expect_identical(recommendations, list("Posit.air-vscode"))
})

test_that("respects existing `settings.json`, but overwrites settings we own", {
  create_local_project()

  dir_create(proj_path(".vscode"))
  path <- file_create(proj_path(".vscode", "settings.json"))

  settings <- list(
    "setting" = list(1L, 2L),
    "[r]" = list(
      "editor.formatOnSave" = FALSE,
      "editor.defaultFormatter" = "not-air"
    ),
    "[rust]" = list(
      "editor.formatOnSave" = FALSE
    ),
    "[quarto]" = list(
      "editor.wordWrap" = "wordWrapColumn"
    )
  )

  jsonlite::write_json(settings, path, auto_unbox = TRUE)

  use_air()

  # Here is all that should change
  settings[["[r]"]][["editor.formatOnSave"]] <- TRUE
  settings[["[r]"]][["editor.defaultFormatter"]] <- "Posit.air-vscode"

  actual_settings <- jsonlite::read_json(path)

  expect_identical(actual_settings, settings)
})

test_that("respects existing `extensions.json`", {
  create_local_project()

  dir_create(proj_path(".vscode"))
  path <- file_create(proj_path(".vscode", "extensions.json"))

  settings <- list(
    "recommendations" = list("this", "that")
  )

  jsonlite::write_json(settings, path, auto_unbox = TRUE)

  use_air()

  settings <- list(
    "recommendations" = list("this", "that", "Posit.air-vscode")
  )

  actual_settings <- jsonlite::read_json(path)

  expect_identical(actual_settings, settings)
})

test_that("does not add to `extensions.json` if already there", {
  create_local_project()

  dir_create(proj_path(".vscode"))
  path <- file_create(proj_path(".vscode", "extensions.json"))

  settings <- list(
    "recommendations" = list("this", "Posit.air-vscode", "that")
  )

  jsonlite::write_json(settings, path, auto_unbox = TRUE)

  use_air()

  actual_settings <- jsonlite::read_json(path)

  expect_identical(actual_settings, settings)
})

test_that("respects existing `.air.toml`", {
  create_local_project()

  content <- c("[format]", "line-width = 90")

  write_utf8(proj_path(".air.toml"), content)

  use_air()

  # Does not make un-dotted form
  expect_false(file_exists(proj_path("air.toml")))

  expect_identical(read_utf8(proj_path(".air.toml")), content)
})

test_that("respects `vscode` option", {
  create_local_package()
  use_air(vscode = FALSE)
  expect_false(dir_exists(proj_path(".vscode")))
})
