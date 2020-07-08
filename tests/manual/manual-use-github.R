pkgload::unload("devtools")
devtools::load_all("~/rrr/usethis")
attachNamespace("devtools")

pkgname <- "klmnop"
use_git_protocol("ssh")
#use_git_protocol("https")
git_protocol()

(pkgpath <- path_temp(pkgname))
create_local_package(pkgpath)
proj_sitrep()

# should fail, not a git repo yet
use_github()

# say YES to the commit
use_git()

# set 'origin'
use_git_remote("origin", "fake-origin-url")

# should fail early because 'origin' is already configured
use_github()

# remove the 'origin' remote
use_git_remote("origin", NULL, overwrite = TRUE)

# should fail, due to lack of auth_token
withr::with_envvar(
  new = c(GITHUB_PAT = NA, GITHUB_TOKEN = NA),
  use_github()
)

# should work
use_github(private = TRUE)

# make sure this reflects ssh vs. https, as appropriate
git_remotes()

# remove the 'origin' remote
use_git_remote("origin", NULL, overwrite = TRUE)

# should fail because GitHub repo already exists
use_github(private = TRUE)

# delete the GitHub repo
(gh_account <- gh::gh_whoami())
pkgname
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = gh_account$login,
  pkg = pkgname
)

# this should work!
use_github(private = TRUE)

# 'master' should have 'origin/master' as upstream
info <- gert::git_info()
expect_equal(info$upstream, "origin/master")

# restore initial project, working directory, delete local repo
withr::deferred_run()

## delete local and remote repo
(gh_account <- gh::gh_whoami())
pkgname
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = gh_account$login,
  pkg = pkgname
)
## alternative: delete from the browser
## view_url(file.path(gh_account$html_url, pkgname, "settings"))
