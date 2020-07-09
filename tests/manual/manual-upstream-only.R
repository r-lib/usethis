pkgload::unload("devtools")
devtools::load_all("~/rrr/usethis")
attachNamespace("devtools")
library(testthat)

x <- create_from_github(
  "r-lib/gh",
  destdir = "~/tmp",
  fork = FALSE,
  open = FALSE,
  protocol = "https"
)
local_project(x)

r <- git_remotes()
expect_equal(r, list(origin = "https://github.com/r-lib/gh.git"))

use_git_remote("upstream", r$origin)
use_git_remote("origin", url = NULL, overwrite = TRUE)

r <- git_remotes()
expect_equal(r, list(upstream = "https://github.com/r-lib/gh.git"))

check_pr_readiness()
err <- rlang::last_error()

expect_s3_class(err, class = "usethis_error_bad_github_config")

# capture github remote data to use in an actual test
# datapasta::dpasta(github_remotes())

withr::deferred_run()
fs::dir_delete(x)
