# Test use_dockerfile()

test_that("use_dockerfile() creates Dockerfile", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(open = FALSE, use_git = TRUE))
  expect_true(file_exists(proj_path("Dockerfile")))
  content <- readLines(proj_path("Dockerfile"))
  expect_match(
    paste(content, collapse = "\n"),
    "Multi-stage build for R package"
  )
})

test_that("use_dockerfile() sets defaults from DESCRIPTION", {
  pkg <- create_local_package()
  desc::desc_set("Suggests" = "quarto", file = proj_path("DESCRIPTION"))
  expect_no_error(use_dockerfile(open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  expect_match(paste(content, collapse = "\n"), "quarto")
})

test_that("use_dockerfile() includes tidyverse when requested", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(use_tidyverse = TRUE, open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "tidyverse")
})

test_that("use_dockerfile() includes tidymodels when requested", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(use_tidymodels = TRUE, open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "tidymodels")
})

test_that("use_dockerfile() includes LaTeX when requested", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(use_latex = TRUE, open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "texlive")
})

test_that("use_dockerfile() includes Quarto when requested", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(use_quarto = TRUE, open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "quarto")
})

test_that("use_dockerfile() creates .dockerignore", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(open = FALSE))
  expect_true(file_exists(proj_path(".dockerignore")))
  content <- readLines(proj_path(".dockerignore"))
  expect_match(paste(content, collapse = "\n"), "\\.git")
})

test_that("use_dockerfile() custom R version", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(R_version = "4.3.2", open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "4.3.2")
})

test_that("use_dockerfile() respects base_image", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(base_image = "r-base", open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "r-base")
})

test_that("use_dockerfile() custom workdir", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(workdir = "/app", open = FALSE))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "/app")
})

test_that("use_dockerfile() additional system packages", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(
    additional_packages = c("curl-dev", "libxml2-dev"),
    open = FALSE
  ))
  content <- readLines(proj_path("Dockerfile"))
  dockerfile_text <- paste(content, collapse = "\n")
  expect_match(dockerfile_text, "curl-dev")
  expect_match(dockerfile_text, "libxml2-dev")
})

test_that("use_dockerfile() outputs expected messages", {
  pkg <- create_local_package()
  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot(
    use_dockerfile(
      R_version = "4.3.2",
      use_quarto = TRUE,
      use_tidyverse = TRUE,
      open = FALSE
    ),
    transform = function(x) {
      x <- gsub("testpkg[0-9a-f]+", "testpkg", x)
      x
    }
  )
})
