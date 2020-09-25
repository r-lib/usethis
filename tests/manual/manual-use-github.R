pkgload::unload("devtools")
devtools::load_all("~/rrr/usethis")
attachNamespace("devtools")

pkgname <- "klmnop"
#use_git_protocol("ssh")
use_git_protocol("https")
git_protocol()

(pkgpath <- path_temp(pkgname))
create_local_package(pkgpath)
proj_sitrep()

# should fail, not a git repo yet
use_github(private = TRUE)

# say YES to the commit
use_git()

# set 'origin'
use_git_remote("origin", "fake-origin-url")

# should fail early because 'origin' is already configured
use_github(private = TRUE)

# remove the 'origin' remote
use_git_remote("origin", NULL, overwrite = TRUE)

# Should fail due to lack of token for this host
# This only works with a PR branch of gitcreds as of 2020-09-24.
# If this stops working, update with whatever approach we adopt for "no creds".
withr::with_envvar(
  new = c(GITHUB_PAT_GITHUB_COM = ""),
  use_github(private = TRUE)
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

# URL and BugReports should be populated
(gh_account <- gh::gh_whoami())
pkgname
URL <- paste0("https://github.com/", gh_account$login, "/", pkgname)
BugReports <- paste0(URL, "/", "issues")
expect_match(desc::desc_get_urls(), URL)
expect_match(desc::desc_get_field("BugReports"), BugReports)

# remove the GitHub links
desc::desc_del(c("BugReports", "URL"))
expect_true(all(!desc::desc_has_fields(c("BugReports", "URL"))))

# restore the GitHub links
# why am I not seeing the warning?
use_github_links(host = "blah")
expect_match(desc::desc_get_urls(), URL)
expect_match(desc::desc_get_field("BugReports"), BugReports)

# overwrite the GitHub links
desc::desc_set_urls("http://example.org")
desc::desc_set(BugReports = "http://example.org")
use_github_links(overwrite = TRUE)
expect_match(desc::desc_get_urls(), URL)
expect_match(desc::desc_get_field("BugReports"), BugReports)

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
