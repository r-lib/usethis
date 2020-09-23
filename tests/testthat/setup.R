if (nzchar(Sys.getenv("CI"))) {
  message("Using GitHub r-lib CI PAT.")
  github_PAT <- paste0(
    "b2b7441d",
    "aeeb010b",
    "1df26f1f6",
    "0a7f1ed",
    "c485e443"
  )
  Sys.setenv(GITHUB_PAT = github_PAT)
}

pre_test_options <- options(
  usethis.quiet = TRUE
)
