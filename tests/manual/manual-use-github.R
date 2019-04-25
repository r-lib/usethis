devtools::load_all()

pkgname <- "klmnop"
#use_git_protocol("ssh")
use_git_protocol("https")
git_protocol()

(pkgpath <- path_temp(pkgname))
create_package(pkgpath, open = FALSE)
proj_set(pkgpath)
setwd(pkgpath)
proj_sitrep()

## should fail, not a git repo yet
use_github()

use_git()

## set 'origin'
git2r::remote_add(git_repo(), "origin", "fake-origin-url")

## should fail early because 'origin' is already configured
use_github()

## remove the 'origin' remote
git2r::remote_remove(git_repo(), "origin")

## should fail, due to lack of auth_token
withr::with_envvar(
  new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = NA),
  use_github()
)

## should create the GitHub repo and configure 'origin', but fail to push,
## due to bad credentials
use_github(credentials = "nope")
## in the shell, in the correct wd, do as we recommend:
## git push --set-upstream origin master
## should succeed (perhaps entering ssh passphrase), refresh browser to verify

## remove the 'origin' remote
git2r::remote_remove(git_repo(), "origin")

## should fail because GitHub repo already exists
use_github()

## delete the GitHub repo
(gh_account <- gh::gh_whoami())
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = gh_account$login,
  pkg = pkgname
)

## should work!

# revisit on my Windows VM
# if (.Platform$OS.type == "windows") {
#   cred <- git2r::cred_ssh_key(
#     publickey = fs::path_home(".ssh/id_rsa.pub"),
#     privatekey = fs::path_home(".ssh/id_rsa")
#   )
# }
use_github()

## restore initial project, presunably usethis itself
proj_set(rstudioapi::getActiveProject())
setwd(proj_get())
proj_sitrep()

## delete local and remote repo
fs::dir_delete(pkgpath)
(gh_account <- gh::gh_whoami())
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = gh_account$login,
  pkg = pkgname
)
## alternative: delete from the browser
## view_url(file.path(gh_account$html_url, pkgname, "settings"))
