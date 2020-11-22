devtools::load_all("~/rrr/usethis")

pkgname <- "grumpy-llama"
(pkgpath <- path_temp(pkgname))
create_local_package(pkgpath)
proj_sitrep()

# say YES to the commit
use_git()

# say YES to the commit
use_github(private = TRUE)

# no non-default branches
pr_resume()
# should exit w/ no big fuss

# no open PRs
pr_fetch()
# should exit w/ no big fuss

pr_init("feature")
use_readme_md(open = FALSE)
gert::git_add("README.md")
gert::git_commit("Add README")

pr_view()
# doesn't work, because current branch no yet associated with a PR

pr_pause()

pr_resume()
# offers to switch to the single existing branch

# remember to actually create the PR in the browser
pr_push()

pr_view()
browse_github_pulls()

pr_fetch()
# presents my one existing PR (the branch I'm on), which I can select

pr_pause()

pr_resume()

# agree to the commit (or not, depending on what you want to test)
use_news_md(open = FALSE)

pr_finish()

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
