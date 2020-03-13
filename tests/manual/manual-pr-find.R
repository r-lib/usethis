# key property of maurolepore/with-no-pr is that there are no open PRs

pkgload::unload("devtools"); devtools::load_all(); attachNamespace("devtools")

# this should not error
prs <- pr_find("maurolepore", repo = "with-no-pr", pr_branch = "new")

# for gh >= v1.1.0
testthat::expect_equal(prs, character())

# for gh < v1.1.0
testthat::expect_equal(prs, "")
