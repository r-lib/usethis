devtools::load_all("~/rrr/usethis")

ghe_host <- "https://github.ubc.ca"
whoami <- gh::gh_whoami(.api_url = ghe_host)
(user <- whoami$login)
pkgname <- "lazy-marmot"
git_protocol()

(pkgpath <- path_temp(pkgname))
create_local_package(pkgpath)
proj_sitrep()

# say YES to the commit
use_git()

use_github(host = ghe_host)

# delete the GitHub repo
gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = user, pkg = pkgname, .api_url = ghe_host
)

# restore initial project, working directory, delete local repo
withr::deferred_run()

# let's do it again by setting an env var
Sys.getenv("GITHUB_API_URL")
withr::local_envvar(GITHUB_API_URL = ghe_host)

create_local_package(pkgpath)
proj_sitrep()

# say YES to the commit
use_git()

use_github()

# delete the GitHub repo
gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = user, pkg = pkgname, .api_url = ghe_host
)

# restore initial project, working directory, delete local repo
withr::deferred_run()
proj_sitrep()
Sys.getenv("GITHUB_API_URL")
