devtools::load_all("~/rrr/usethis")
library(testthat)
library(fs)

# comment / uncomment to test against GHE
# Sys.setenv(GITHUB_API_URL = "https://github.ubc.ca")
# lesson learned: UBC is still running GHE 2.21 and the syntax around
# source branch and path has changed in GHE 2.22, which seems to match
# github.com
# some of this stuff works, but not all
# not going to worry about supporting older versions of GHE fully

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

# should fail because this branch does not exist
use_github_pages(branch = "nope")

# should work
use_github_pages()

# change branch and path
use_github_pages(branch = git_branch_default(), path = "/docs")

# go back to default branch and path
use_github_pages()

# customize domain name
use_github_pages(cname = "example.org")

# clear custom domain name, change path
use_github_pages(path = "/docs", cname = NULL)

# clean up
gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = me, pkg = repo_name
)
withr::deferred_run()
expect_false(dir_exists(path_home("tmp", repo_name)))
