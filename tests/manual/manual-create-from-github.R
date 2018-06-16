load_all()
library(testthat)

## this repo was chosen because it was first one listed for the cran gh user
## i.e., totally arbitrary
dir_delete("~/Desktop/TailRank/")

## I assume a PAT is configured
gh::gh_whoami()

## create from repo I do not have push access to
## fork = FALSE
create_from_github("cran/TailRank", fork = FALSE)
dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = TRUE
create_from_github("cran/TailRank", fork = TRUE)
## fork and clone --> should see origin and upstream remotes
expect_setequal(
  git2r::remotes(git2r::repository(proj_get())),
  c("origin", "upstream")
)
dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = NA
create_from_github("cran/TailRank", fork = NA)
## fork and clone --> should see origin and upstream remotes
expect_setequal(
  git2r::remotes(git2r::repository(proj_get())),
  c("origin", "upstream")
)
dir_delete("~/Desktop/TailRank/")

## a repo I created just for testing
dir_delete("~/Desktop/ethel/")

## create from repo I DO have push access to
## fork = FALSE
create_from_github("jennybc/ethel", fork = FALSE)
## make a local edit and push to confirm origin remote is properly setup
dir_delete("~/Desktop/ethel")

## create from repo I do have push access to
## fork = TRUE
create_from_github("jennybc/ethel", fork = TRUE)
## expect error because I own it and can't fork it

## create from repo I do have push access to
## fork = NA
create_from_github("jennybc/ethel", fork = NA)
## gets created, as clone but no fork
dir_delete("~/Desktop/ethel")

## store my PAT
token <- gh_token()

## make my PAT unavailable via env vars
Sys.unsetenv(c("GITHUB_PAT", "GITHUB_TOKEN"))
gh::gh_whoami()

dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = FALSE
create_from_github("cran/TailRank", fork = FALSE)
## created, clone, origin remote is cran/TailRank
expect_setequal(git2r::remotes(git2r::repository(proj_get())), "origin")
expect_setequal(
  git2r::remote_url(git2r::repository(proj_get())),
  "git@github.com:cran/TailRank.git"
)
dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = TRUE
create_from_github("cran/TailRank", fork = TRUE)
## expect error because PAT not available

## create from repo I do not have push access to
## fork = NA
create_from_github("cran/TailRank", fork = NA)
## created as clone (no fork)
dir_delete("~/Desktop/TailRank")

## create from repo I do not have push access to
## fork = TRUE, explicitly provide token
create_from_github("cran/TailRank", fork = TRUE, auth_token = token)
## fork and clone
