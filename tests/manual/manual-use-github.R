devtools::load_all()
library(fs)

pkgname <- "klmnop"
protocol <- "ssh"
#protocol <- "https"

(pkgpath <- path_temp(pkgname))
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
if (.Platform$OS.type == "windows") {
  cred <- git2r::cred_ssh_key(
    publickey = fs::path_home(".ssh/id_rsa.pub"),
    privatekey = fs::path_home(".ssh/id_rsa")
  )
} else {
  cred <- NULL
}
use_github(protocol = protocol, credentials = cred)

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
