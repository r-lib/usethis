pre_test_options <- options(usethis.quiet = TRUE)
withr::defer(options(pre_test_options), teardown_env())
