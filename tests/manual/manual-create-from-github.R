load_all()

## this repo was chosen because it was first one listed for the cran gh user
## i.e., totally arbitrary
dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## I assume a PAT is configured
gh::gh_whoami()

## create from repo I do not have push access to
## fork = FALSE
create_from_github("cran/TailRank", fork = FALSE)
dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## create from repo I do not have push access to
## fork = TRUE
create_from_github("cran/TailRank", fork = TRUE)
## fork and clone --> should see origin and upstream remotes
dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## create from repo I do not have push access to
## fork = NA
create_from_github("cran/TailRank", fork = NA)
## fork and clone --> should see origin and upstream remotes
dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## a repo I created just for testing
dir_delete("~/Desktop/fluffy-otter/", recursive = TRUE)

## create from repo I DO have push access to
## fork = FALSE
create_from_github("jennybc/fluffy-otter", fork = FALSE)
## make a local edit and push to confirm origin remote is properly setup
dir_delete("~/Desktop/fluffy-otter/", recursive = TRUE)

## create from repo I do have push access to
## fork = TRUE
create_from_github("jennybc/fluffy-otter", fork = TRUE)
## expect error because I own it and can't fork it

## create from repo I do have push access to
## fork = NA
create_from_github("jennybc/fluffy-otter", fork = NA)
## gets created, as clone but no fork

## store my PAT
token <- gh_token()

## make my PAT unavailable via env vars
Sys.unsetenv(c("GITHUB_PAT", "GITHUB_TOKEN"))
gh::gh_whoami()

dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## create from repo I do not have push access to
## fork = FALSE
create_from_github("cran/TailRank", fork = FALSE)
## created, clone, origin remote is cran/TailRank
dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## create from repo I do not have push access to
## fork = TRUE
create_from_github("cran/TailRank", fork = TRUE)
## expect error because PAT not available

## create from repo I do not have push access to
## fork = NA
create_from_github("cran/TailRank", fork = NA)
## created as clone (no fork)
dir_delete("~/Desktop/TailRank/", recursive = TRUE)

## create from repo I do not have push access to
## fork = TRUE, explicitly provide token
create_from_github("cran/TailRank", fork = TRUE, auth_token = token)
## fork and clone
