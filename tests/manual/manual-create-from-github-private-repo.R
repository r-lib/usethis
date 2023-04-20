devtools::load_all("~/rrr/usethis")
library(testthat)
library(fs)

repo_name <- "crewsocks"
gh_account <- gh::gh_whoami()
(me <- gh_account$login)

# remove any pre-existing repo
gh::gh(
  "DELETE /repos/:username/:pkg",
  username = me, pkg = repo_name
)
dir_delete(path(usethis:::conspicuous_place(), repo_name))
expect_false(dir_exists(path(usethis:::conspicuous_place(), repo_name)))

# create the repo
gh::gh(
  "POST /user/repos",
  name = repo_name,
  description = "usethis manual test repo",
  auto_init = TRUE, # note this means default branch will be `main`
  private = TRUE
)

## this should work
x <- create_from_github(paste0(me, "/", repo_name), open = FALSE)

expect_equal(path_file(x), "crewsocks")
expect_true(dir_exists(x))
expect_true(file_exists(path(x, "crewsocks.Rproj")))
expect_match(
  gert::git_remote_list(repo = x)$url,
  "^https"
)

## cleanup
dir_delete(x)

gh::gh(
  "DELETE /repos/:username/:pkg",
  username = me, pkg = repo_name
)
