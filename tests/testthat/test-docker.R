# Test use_dockerfile()

test_that("use_dockerfile() creates Dockerfile", {
  pkg <- create_local_package()
  expect_no_error(use_dockerfile(open = FALSE, use_git = TRUE))
  expect_true(file_exists(proj_path("Dockerfile")))
  content <- readLines(proj_path("Dockerfile"))
  expect_match(paste(content, collapse = "\n"), "Multi-stage build for R package")
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

test_that("use_dockerfile() preserves case-sensitive package names", {
  pkg <- create_local_package()
  desc::desc_set(
    "Imports" = "DBI, clubSandwich, dplyr",
    file = proj_path("DESCRIPTION")
  )
  use_dockerfile(open = FALSE)
  content <- paste(readLines(proj_path("Dockerfile")), collapse = "\n")
  expect_match(content, "DBI")
  expect_match(content, "clubSandwich")
  expect_match(content, "dplyr")
  expect_no_match(content, "dbi")
  expect_no_match(content, "clubsandwich")
})

test_that("use_dockerfile() uses character(0) when no R packages needed", {
  pkg <- create_local_package()
  use_dockerfile(open = FALSE)
  content <- paste(readLines(proj_path("Dockerfile")), collapse = "\n")
  expect_match(content, "character\\(0\\)")
  expect_no_match(content, 'c\\(""\\)')
})

test_that("use_dockerfile() errors on vector R_version", {
  pkg <- create_local_package()
  expect_snapshot(
    use_dockerfile(R_version = c("4.3.0", "4.4.0"), open = FALSE),
    error = TRUE
  )
})

test_that("use_dockerfile() errors when base_image includes a tag", {
  pkg <- create_local_package()
  expect_snapshot(
    use_dockerfile(base_image = "rocker/r-ver:4.3.3", open = FALSE),
    error = TRUE
  )
})

test_that("use_dockerfile() uses PPM repo by default", {
  pkg <- create_local_package()
  use_dockerfile(open = FALSE)
  content <- paste(readLines(proj_path("Dockerfile")), collapse = "\n")
  expect_match(content, "packagemanager.rstudio.com")
})

test_that("use_dockerfile() creates non-root user", {
  pkg <- create_local_package()
  use_dockerfile(open = FALSE)
  content <- paste(readLines(proj_path("Dockerfile")), collapse = "\n")
  expect_match(content, "id -u ruser")
  expect_match(content, "useradd")
})

test_that("use_dockerfile() does not copy redundant system binaries", {
  pkg <- create_local_package()
  use_dockerfile(open = FALSE)
  content <- paste(readLines(proj_path("Dockerfile")), collapse = "\n")
  expect_no_match(content, "COPY --from=builder /usr/bin")
  expect_no_match(content, "COPY --from=builder /usr/local/bin")
})

