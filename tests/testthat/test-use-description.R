context("use_description")

test_that("use_description() defaults to field values built into usethis", {
  scoped_temporary_project()
  capture.output(use_description())
  d <- desc::desc(proj_get())
  expect_identical(as.character(d$get_version()), "0.0.0.9000")
  expect_match(d$get("Title"), "What the Package Does")
  expect_match(d$get("Description"), "What the package does")
  author <- d$get_author()
  expect_is(author, class = "person")
  expect_equivalent(
    unclass(author)[[1]],
    list(
      given = "First", family = "Last", role = c("aut", "cre"),
      email = "first.last@example.com", comment = NULL
    )
  )
  expect_match(d$get("License"), "What license it uses")
  expect_match(d$get("Encoding"), "UTF-8")
  expect_match(d$get("LazyData"), "true")
})

test_that("use_description(): user's fields > usethis defaults", {
  scoped_temporary_project()
  capture.output(use_description(
    fields = list(Title = "aaa", URL = "https://www.r-project.org")
  ))
  d <- desc::desc(proj_get())
  ## from user's fields
  expect_match(d$get("Title"), "aaa")
  expect_match(d$get("URL"), "https://www.r-project.org")
  ## from usethis defaults
  expect_match(d$get("Description"), "What the package does")
  expect_match(d$get("Encoding"), "UTF-8")
})

test_that("use_description(): usethis options > usethis defaults", {
  withr::with_options(
    list(
      usethis.description = list(
        License = "MIT + file LICENSE",
        Version = "1.0.0"
      )
    ),
    {
      scoped_temporary_project()
      capture.output(use_description())
      d <- desc::desc(proj_get())
      ## from usethis options
      expect_match(d$get("License"), "MIT + file LICENSE", fixed = TRUE)
      expect_identical(as.character(d$get_version()), "1.0.0")
      ## from usethis defaults
      expect_match(d$get("Description"), "What the package does")
    }
  )
})

test_that("use_description(): devtools options can be picked up", {
  withr::with_options(
    list(
      devtools.desc = list(
        License = "MIT + file LICENSE",
        Version = "1.0.0"
      )
    ),
    {
      scoped_temporary_project()
      capture.output(use_description())
      d <- desc::desc(proj_get())
      ## from devtools options
      expect_match(d$get("License"), "MIT + file LICENSE", fixed = TRUE)
      expect_identical(as.character(d$get_version()), "1.0.0")
      ## from usethis defaults
      expect_match(d$get("Description"), "What the package does")
    }
  )
})

test_that("use_description(): user's fields > options > defaults", {
  withr::with_options(
    list(usethis.description = list(Version = "1.0.0")),
    {
      scoped_temporary_project()
      capture.output(use_description(
        fields = list(Title = "aaa")
      ))
      d <- desc::desc(proj_get())
      ## from user's fields
      expect_match(d$get("Title"), "aaa")
      ## from usethis options
      expect_identical(as.character(d$get_version()), "1.0.0")
      ## from usethis defaults
      expect_match(d$get("Description"), "What the package does")
    }
  )
})
