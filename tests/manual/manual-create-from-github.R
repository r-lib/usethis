devtools::load_all("~/rrr/usethis")
library(fs)

# maybe set a protocol
#use_git_protocol("ssh")
git_protocol()

# check that a GitHub PAT is configured
(gh_account <- gh::gh_whoami())
(me <- gh_account$login)

# this repo was chosen because it was first one listed for the cran gh user
# the day I made this, i.e., it's totally arbitrary

# make sure local copy does not exist; this will error if doesn't pre-exist
dir_delete("~/tmp/TailRank")

# make sure user doesn't have pre-existing fork; this will 404 if not
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = me,
  pkg = "TailRank"
)

# create from repo I do not have push access to
# fork = FALSE
x <- create_from_github("cran/TailRank", destdir = "~/tmp", fork = FALSE, open = FALSE)
with_project(x, git_sitrep())
dir_delete(x)

# create from repo I do not have push access to
# fork = TRUE
x <- create_from_github("cran/TailRank", destdir = "~/tmp", fork = TRUE, open = FALSE)
# fork and clone --> should see origin and upstream remotes
gert::git_branch_list(x, repo = x)
expect_setequal(
  gert::git_remote_list(repo = x)$name,
  c("origin", "upstream")
)
expect_equal(
  with_project(x, usethis:::git_branch_tracking()),
  "upstream/master"
)
dir_delete(x)
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = me,
  pkg = "TailRank"
)

# create from repo I do not have push access to
# fork = NA
x <- create_from_github("cran/TailRank", destdir = "~/tmp", fork = NA, open = FALSE)
# fork and clone --> should see origin and upstream remotes
expect_setequal(
  gert::git_remote_list(repo = x)$name,
  c("origin", "upstream")
)
dir_delete(x)

gh::gh(
  "DELETE /repos/:username/:pkg",
  username = me,
  pkg = "TailRank"
)

# a repo I created just for testing, make sure local copy doesn't pre-exist
dir_delete("~/tmp/ethel")

# create from repo I DO have push access to
# fork = FALSE
x <- create_from_github("jennybc/ethel", "~/tmp", fork = FALSE, open = TRUE)
# go make a local edit and push to confirm origin remote is properly setup
dir_delete(x)

# create from repo I do have push access to
# fork = TRUE
x <- create_from_github("jennybc/ethel", destdir = "~/tmp", fork = TRUE, open = FALSE)
# expect error because I own it and can't fork it
# make sure we didn't leave an empty directory behind
expect_false(dir_exists("~/tmp/ethel"))

# create from repo I do have push access to
# fork = NA
x <- create_from_github("jennybc/ethel", destdir = "~/tmp", fork = NA, open = FALSE)
# gets created, as clone but no fork
dir_delete(x)

# explore "no token" situations
gitcreds::gitcreds_delete()
gh::gh_whoami()

dir_delete("~/tmp/TailRank")

# create from repo I do not have push access to
# fork = FALSE
x <- create_from_github("cran/TailRank", destdir = "~/tmp", fork = FALSE, open = FALSE)
# created, clone, origin remote is cran/TailRank
dat <- gert::git_remote_list(repo = x)
expect_equal(dat$name, "origin")
#expect_equal(dat$url, "git@github.com:cran/TailRank.git")
expect_equal(dat$url, "https://github.com/cran/TailRank.git")

dir_delete(x)

# create from repo I do not have push access to
# fork = TRUE
x <- create_from_github("cran/TailRank", destdir = "~/tmp", fork = TRUE, open = FALSE)
# expect error because PAT not available

# create from repo I do not have push access to
# fork = NA
x <- create_from_github("cran/TailRank", destdir = "~/tmp", fork = NA, open = FALSE)
# expect error because PAT not available AND fork = NA
