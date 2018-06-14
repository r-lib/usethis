load_all()

pkgname <- "fghij"
protocol <- "ssh"
#protocol <- "https"

pkgpath <- path_temp(pkgname)
create_package(pkgpath, open = FALSE)

## should fail, not a git repo yet
use_github(protocol = "https")

use_git()

## should fail, due to lack of auth_token
withr::with_envvar(
  new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = NA),
  use_github()
)

## should work!
use_github(protocol = protocol)

## delete local and remote repo
dir_delete(pkgpath)
(gh_account <- gh::gh_whoami())
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = gh_account$login,
  pkg = pkgname
)
## alternative: delete from the browser
## view_url(file.path(gh_account$html_url, pkgname, "settings"))
