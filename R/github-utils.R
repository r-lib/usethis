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
  paste0(gh_tree_remote(path), collapse = "/")
}

## repo_spec --> owner, repo
## TODO: could use more general facilities for parsing GitHub URL/spec
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    stop_glue("{ui_code('repo_spec')} must be of form {ui_value('owner/repo')}.")
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo
