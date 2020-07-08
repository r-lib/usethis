pkgload::unload("devtools")
devtools::load_all("~/rrr/usethis")
attachNamespace("devtools")
library(testthat)

x <- create_from_github(
  "r-lib/gh",
  destdir = "~/tmp",
  fork = TRUE,
  open = FALSE,
  protocol = "https"
)
local_project(x)

(r <- git_remotes())
# r-pkgs is what r-lib used to be called
use_git_remote("upstream", sub("r-lib", "r-pkgs", r$upstream), overwrite = TRUE)

(r <- git_remotes())
expect_equal(r$origin, "https://github.com/jennybc/gh.git")
expect_equal(r$upstream, "https://github.com/r-pkgs/gh.git")

check_pr_readiness()
err <- rlang::last_error()

expect_s3_class(err, class = "usethis_error_bad_github_config")

# capture github remote data to use in an actual test
# datapasta::dpasta(github_remotes())

withr::deferred_run()
fs::dir_delete(x)
