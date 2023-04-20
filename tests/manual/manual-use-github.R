devtools::load_all("~/rrr/usethis")

pkgname <- "taciturn-tern"
#use_git_protocol("ssh")
#use_git_protocol("https")
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

# should work
use_github(private = TRUE)

# make sure this reflects ssh vs. https, as appropriate
git_remotes()

# remove the 'origin' remote
use_git_remote("origin", NULL, overwrite = TRUE)

# should fail because GitHub repo already exists
use_github(private = TRUE)

# delete the GitHub repo
whoami <- gh::gh_whoami()
gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = whoami$login,
  pkg = pkgname
)

# this should work!
use_github(private = TRUE)

# 'master' should have 'origin/master' as upstream
info <- gert::git_info()
expect_equal(info$upstream, "origin/master")

# URL and BugReports should be populated
URL <- paste0("https://github.com/", whoami$login, "/", pkgname)
BugReports <- paste0(URL, "/", "issues")
expect_match(desc::desc_get_urls(), URL)
expect_match(desc::desc_get_field("BugReports"), BugReports)

# remove the GitHub links
desc::desc_del(c("BugReports", "URL"))
expect_true(all(!desc::desc_has_fields(c("BugReports", "URL"))))

# restore the GitHub links
# should see a warning that `host` is deprecated and ignored
use_github_links(host = "blah")
expect_match(desc::desc_get_urls(), URL)
expect_match(desc::desc_get_field("BugReports"), BugReports)

# overwrite the GitHub links
desc::desc_set_urls("http://example.org")
desc::desc_set(BugReports = "http://example.org")
use_github_links(overwrite = TRUE)
expect_match(desc::desc_get_urls(), URL)
expect_match(desc::desc_get_field("BugReports"), BugReports)


gh::gh(
  "DELETE /repos/{username}/{pkg}",
  username = whoami$login,
  pkg = pkgname
)
usethis::use_git_remote("origin", url = NULL, overwrite = TRUE)

# only do this if you're willing to restore your PAT
gitcreds::gitcreds_delete()
# should error, because no PAT
use_github(private = TRUE)
# don't forget to restore your PAT
gitcreds::gitcreds_set()

# restore initial project, working directory, delete local repo
withr::deferred_run()

## delete local and remote repo
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = whoami$login,
  pkg = pkgname
)
