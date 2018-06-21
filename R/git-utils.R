git_uncommitted <- function(path = proj_get()) {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

check_uncommitted_changes <- function(path = proj_get()) {
  if (uses_git(path) && git_uncommitted(path)) {
    stop_glue("Uncommited changes. Please commit to git before continuing.")
  }
}

## suppress the warning about multiple remotes, which is triggered by
## the common "origin" and "upstream" situation, e.g., fork and clone
gh_tree_remote <- function(path) {
  suppressWarnings(gh::gh_tree_remote(path))
}

## Git remotes --> filter for GitHub --> owner, repo, repo_spec
github_owner <- function(path = proj_get()) {
  gh_tree_remote(path)[["username"]]
}

github_repo <- function(path = proj_get()) {
  gh_tree_remote(path)[["repo"]]
}

github_repo_spec <- function(path = proj_get()) {
  collapse(gh_tree_remote(path), sep = "/")
}

## repo_spec --> owner, repo
## TODO: could use more general facilities for parsing GitHub URL/spec
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    stop_glue("{code('repo_spec')} must be of form {value('owner/repo')}.")
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo
