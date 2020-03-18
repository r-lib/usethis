test_that("release bullets don't change accidentally", {
  # Avoid finding any files in real usethis project
  old <- proj_set(dir_create(path_temp("usethis")), force = TRUE)
  on.exit(proj_set(old))

  verify_output(test_path("test-release-usethis.txt"), {
    "# First release"
    cat(release_checklist("0.1.0", on_cran = FALSE), sep = "\n")

    "# Patch release"
    cat(release_checklist("0.0.1", on_cran = TRUE), sep = "\n")

    "# Major release"
    cat(release_checklist("1.0.0", on_cran = TRUE), sep = "\n")
  })
})

test_that("get extra news bullets if available", {
  standard <- release_checklist("1.0.0", TRUE)

  attach(
    list(release_bullets = function() "Extra bullets"),
    name = "extra",
    warn.conflicts = FALSE
  )
  on.exit(detach("extra"))

  new <- setdiff(release_checklist("1.0.0", TRUE), standard)
  expect_equal(new, "* [ ] Extra bullets")
})
