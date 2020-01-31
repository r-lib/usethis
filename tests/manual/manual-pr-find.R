test_that("pr_find with a repo with no pr and a new pr outputs character()", {
  expect_error_free(
    pr_find("maurolepore", repo = "with-no-pr", pr_branch = "new")
  )
})

test_that("pr_find with a repo with some pr and a new pr outputs character()", {
  expect_error_free(
    pr_find("maurolepore", repo = "with-some-pr", pr_branch = "new")
  )
})
