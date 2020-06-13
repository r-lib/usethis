#' Gather data on GitHub-associated remotes
#'
#' Creates a data frame where each row represents a GitHub-associated remote.
#'
#' @param these Intersect the list of GitHub-associated remotes with these
#'   remote names. To see all GitHub-associated remotes, use `these = NULL` or
#'   `these = character()`.
#' @inheritParams use_github
#' @keywords internal
#' @noRd
github_remotes2 <- function(these = c("origin", "upstream"),
                            auth_token = github_token(),
                            host = "https://api.github.com") {
  grl <- data.frame(
    remote = NA_character_,
    url = NA_character_,
    gh_owner = NA_character_,
    gh_repo = NA_character_,
    fork = NA,
    permissions_admin = NA,
    permissions_push = NA,
    permissions_pull = NA,
    gh_parent_owner = NA_character_,
    gh_parent_repo = NA_character_,
    gh_parent_permissions_admin = NA,
    gh_parent_permissions_push = NA,
    gh_parent_permissions_pull = NA,
    stringsAsFactors = FALSE
  )
  
  x <- gert::git_remote_list(git_repo())
  is_github <- grepl("github", x$url)
  is_one_of_these <- if (length(these) > 0) x$name %in% these else TRUE
  x <- x[is_github & is_one_of_these, ]
  if (nrow(x) == 0) {
    return(grl[0, ])
  }
  grl <- grl[rep_len(1, nrow(x)), ]
  
  grl$remote <- x$name
  grl$url <- x$url
  
  parsed <- parse_github_remotes(grl$url)
  grl$gh_owner <- purrr::map_chr(parsed, "owner")
  grl$gh_repo <- purrr::map_chr(parsed, "repo")
  
  get_gh_repo <- function(owner, repo, auth_token, host) {
    if (is.na(owner) || is.na(repo)) {
      NULL
    } else {
      gh::gh(
        "GET /repos/:owner/:repo",
        owner = owner, repo = repo,
        .api_url = host,.token = auth_token
      )
    }
  }
  gh_info <- purrr::map2(
    grl$gh_owner, grl$gh_repo,
    ~ get_gh_repo(.x, .y,  auth_token = auth_token, host = host)
  )
  grl$fork <- purrr::map_lgl(gh_info, "fork")
  grl$permissions_admin <- purrr::map_lgl(gh_info, c("permissions", "admin"))
  grl$permissions_push <- purrr::map_lgl(gh_info, c("permissions", "push"))
  grl$permissions_pull <-purrr::map_lgl(gh_info, c("permissions", "pull"))
  grl$gh_parent_owner <-
    purrr::map_chr(gh_info, c("parent", "owner", "login"), .default = NA)
  grl$gh_parent_repo <-
    purrr::map_chr(gh_info, c("parent", "name"), .default = NA)
  gh_parent_info <- purrr::map2(
    grl$gh_parent_owner, grl$gh_parent_repo,
    ~ get_gh_repo(.x, .y,  auth_token = auth_token, host = host)
  )
  grl$gh_parent_permissions_admin <-
    purrr::map_lgl(gh_parent_info, c("permissions", "admin"), .default = NA)
  grl$gh_parent_permissions_push <-
    purrr::map_lgl(gh_parent_info, c("permissions", "push"), .default = NA)
  grl$gh_parent_permissions_pull <-
    purrr::map_lgl(gh_parent_info, c("permissions", "pull"), .default = NA)
  grl
}

#' Classify the GitHub remote configuration
#'
#' @description
#' Classify the active project's GitHub remote situation, so diagnostic and
#' other downstream functions can decide whether to scold/fix/proceed/abort.
#' We only consider the remotes where:
#' * Name is `origin` or `upstream` and URL contains the string `"github"`
#'
#' We assume the project is a Git repo, so use this behind a guard like
#' `check_uses_git()`.
#'
#' Possible return values, the simple cases we expect to see frequently:
#' * no_github: No `origin`, no `upstream`.
#' * ours: `origin` exists, is not a fork, and we can push to it. Owner of
#'   `origin` could be current user, another user, or an org. No `upstream`.
#' * theirs: `origin` exists, is not a fork, and we can NOT push to it. No
#'   `upstream`.
#' * fork: `origin` exists and we can push to it. `origin` is a fork of the repo
#'   configured as `upstream`. We may or may not be able to push to `upstream`.
#' * fork_no_upstream: `origin` exists and we can push to it. `origin` is a fork
#'   but there's no `upstream`.
#'
#' Possible return values, the weird cases:
#' * unsupported_upstream_only: `upstream` exists but `origin` does not.
#' * unsupported_fork_origin_read_only: `origin` exists, it's a fork, but we
#'   can't push to `origin`. `upstream` may or may not be configured.
#' * unsupported_origin_upstream_fork_mismatch: `origin` exists, it's a fork of
#'   something, but that is not the repo associated with `upstream`.
#' * unsupported_origin_upstream_non_fork: `origin` and `upstream` both exist,
#'   but `origin` is not a fork.
#' * unsupported_uncaught: This really shouldn't happen. It means there's a case
#'   not covered by all of the above.
#'
#' @inheritParams use_github
#' @keywords internal
#' @noRd
classify_github_setup <- function(auth_token = github_token(),
                                  host = "https://api.github.com") {
  grl <- github_remotes2(auth_token = auth_token, host = host)
  if (nrow(grl) == 0) {
    return("no_github")
  }
  # grl describes origin, upstream, or (origin and upstream)
  
  if (identical(grl$remote, "upstream")) {
    return("unsupported_upstream_only")
  }
  # grl describes origin or (origin and upstream)
  
  if (identical(grl$remote, "origin")) {
    if (grl$fork) {
      if (grl$permissions_push) {
        return("fork_no_upstream")
      } else {
        return("unsupported_fork_origin_read_only")
      }
    } else {
      if (grl$permissions_push) {
        # TODO: remains to be seen if I need to distinguish 'mine' from 'ours'
        return("ours")
      } else {
        return("theirs")
      }
    }
  }
  # grl describes (origin and upstream)
  
  origin <- grl[grl$remote == "origin",]
  upstream <- grl[grl$remote == "upstream",]
  origin_parent_spec <- glue_data(origin, "{gh_parent_owner}/{gh_parent_repo}")
  upstream_spec <- glue_data(upstream, "{gh_owner}/{gh_repo}")
  if (origin$fork) {
    if (identical(origin_parent_spec, upstream_spec)) {
      if (origin$permissions_push) {
        return("fork")
      } else {
        return("unsupported_fork_origin_read_only")
      }
    } else {
      return("unsupported_origin_upstream_fork_mismatch")
    }
  } else {
    return("unsupported_origin_upstream_non_fork")
  }
  
  "unsupported_uncaught"
}
