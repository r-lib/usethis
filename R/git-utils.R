git_uncommitted <- function(path = proj_get()) {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

check_uncommitted_changes <- function(path = proj_get()) {
  if (uses_git(path) && git_uncommitted(path)) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }
}

## Git remotes --> filter for GitHub --> owner, repo, repo_spec
github_owner <- function(path = proj_get()) {
  gh::gh_tree_remote(path)[["username"]]
}

github_repo <- function(path = proj_get()) {
  gh::gh_tree_remote(path)[["repo"]]
}

github_repo_spec <- function(path = proj_get()) {
  paste0(gh::gh_tree_remote(path), collapse = "/")
}

## repo_spec --> owner, repo
## TODO: could use more general facilities for parsing GitHub URL/spec
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    stop(
      code("repo_spec"), " must be of form ", value("owner/repo"),
      call. = FALSE
    )
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo
