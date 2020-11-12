devtools::load_all("~/rrr/usethis")
library(testthat)
library(fs)

repo_name <- "stacey"
gh_account <- gh::gh_whoami()
(me <- gh_account$login)

# remove any pre-existing repo and local project
gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = me, pkg = repo_name
)
dir_delete(path_home("tmp", repo_name))
expect_false(dir_exists(path_home("tmp", repo_name)))

# create the package
create_local_package(path_home("tmp", "stacey"))
use_git()
use_github()

use_tidy_pkgdown()

# clean up
gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = me, pkg = repo_name
)
withr::deferred_run()
expect_false(dir_exists(path_home("tmp", repo_name)))
