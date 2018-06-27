devtools::load_all()
library(testthat)
library(fs)

## this repo was chosen because it was first one listed for the cran gh user
## the day I made this, i.e., it's totally arbitrary

## make sure local copy does not exist; this will error if doesn't pre-exist
dir_delete("~/Desktop/TailRank/")

## check that a GitHub PAT is configured
gh::gh_whoami()

## create from repo I do not have push access to
## fork = FALSE
if (.Platform$OS.type == "windows") {
  cred <- git2r::cred_ssh_key(
    publickey = fs::path_home(".ssh/id_rsa.pub"),
    privatekey = fs::path_home(".ssh/id_rsa")
  )
} else {
  cred <- NULL
}
create_from_github("cran/TailRank", fork = FALSE, credentials = cred)
dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = TRUE
create_from_github("cran/TailRank", fork = TRUE, credentials = cred)
## fork and clone --> should see origin and upstream remotes
expect_setequal(
  git2r::remotes(git2r::repository("~/Desktop/TailRank/")),
  c("origin", "upstream")
)
dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = NA
create_from_github("cran/TailRank", fork = NA, credentials = cred)
## fork and clone --> should see origin and upstream remotes
expect_setequal(
  git2r::remotes(git2r::repository("~/Desktop/TailRank/")),
  c("origin", "upstream")
)
dir_delete("~/Desktop/TailRank/")

## a repo I created just for testing, make sure local copy doesn't pre-exist
dir_delete("~/Desktop/ethel/")

## create from repo I DO have push access to
## fork = FALSE
create_from_github("jennybc/ethel", fork = FALSE, credentials = cred)
## go make a local edit and push to confirm origin remote is properly setup
dir_delete("~/Desktop/ethel")

## create from repo I do have push access to
## fork = TRUE
create_from_github("jennybc/ethel", fork = TRUE, credentials = cred)
## expect error because I own it and can't fork it

## create from repo I do have push access to
## fork = NA
create_from_github("jennybc/ethel", fork = NA, credentials = cred)
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
create_from_github("cran/TailRank", fork = FALSE, credentials = cred)
## created, clone, origin remote is cran/TailRank
expect_setequal(
  git2r::remotes(git2r::repository("~/Desktop/TailRank/")),
  "origin"
)
expect_setequal(
  git2r::remote_url(git2r::repository("~/Desktop/TailRank/")),
  "git@github.com:cran/TailRank.git"
)
dir_delete("~/Desktop/TailRank/")

## create from repo I do not have push access to
## fork = TRUE
create_from_github("cran/TailRank", fork = TRUE, credentials = cred)
## expect error because PAT not available

## create from repo I do not have push access to
## fork = NA
create_from_github("cran/TailRank", fork = NA, credentials = cred)
## created as clone (no fork)
dir_delete("~/Desktop/TailRank")

## create from repo I do not have push access to
## fork = TRUE, explicitly provide token
create_from_github(
  "cran/TailRank", fork = TRUE, auth_token = token, credentials = cred
)
## fork and clone

dir_delete("~/Desktop/TailRank")
