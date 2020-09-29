devtools::load_all("~/rrr/usethis")

pkgname <- "qrstuv"
#use_git_protocol("ssh")
#use_git_protocol("https")
git_protocol()

(pkgpath <- path_temp(pkgname))
create_local_package(pkgpath)
proj_sitrep()

# say YES to the commit
use_git()

use_github(host = "https://github.ubc.ca")

# delete the GitHub repo
(gh_account <- gh::gh_whoami(.api_url = "https://github.ubc.ca"))
pkgname
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = gh_account$login,
  pkg = pkgname,
  .api_url = "https://github.ubc.ca"
)

# restore initial project, working directory, delete local repo
withr::deferred_run()


create_from_github(
  "ubc-mds/instructor-guides", destdir = "~/tmp", fork = TRUE,
  host = "https://github.ubc.ca"
)
