#' Gather data on GitHub-associated remotes
#'
#' Creates a data frame where each row represents a GitHub-associated remote.
#' The data frame is initialized via `gert::git_remote_list()`, possibly
#' filtered for specific remotes, then built out with data from the GitHub API.
#'
#' @param these Intersect the list of GitHub-associated remotes with `these`
#'   remote names. To keep all GitHub-associated remotes, use `these = NULL` or
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
    repo_owner = NA_character_,
    repo_name = NA_character_,
    is_fork = NA,
    can_push = NA,
    parent_repo_owner = NA_character_,
    parent_repo_name = NA_character_,
    can_push_to_parent = NA,
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
  grl$repo_owner <- map_chr(parsed, "owner")
  grl$repo_name <- map_chr(parsed, "repo")

  get_gh_repo <- function(owner, repo) {
    if (is.na(owner) || is.na(repo)) {
      NULL
    } else {
      gh::gh(
        "GET /repos/:owner/:repo",
        owner = owner, repo = repo,
        .api_url = host, .token = auth_token
      )
    }
  }

  repo_info <- purrr::map2(grl$repo_owner, grl$repo_name, get_gh_repo)
  grl$is_fork <- map_lgl(repo_info, "fork")
  grl$can_push <- map_lgl(repo_info, c("permissions", "push"))
  grl$parent_repo_owner <-
    map_chr(repo_info, c("parent", "owner", "login"), .default = NA)
  grl$parent_repo_name <-
    map_chr(repo_info, c("parent", "name"), .default = NA)

  parent_info <- purrr::map2(
    grl$parent_repo_owner, grl$parent_repo_name,
    get_gh_repo
  )
  grl$can_push_to_parent <-
    map_lgl(parent_info, c("permissions", "push"), .default = NA)

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
#' Possible GitHub remote configurations, the common cases:
#' * no_github: No `origin`, no `upstream`.
#' * ours: `origin` exists, is not a fork, and we can push to it. Owner of
#'   `origin` could be current user, another user, or an org. No `upstream`.
#' * theirs: `origin` exists, is not a fork, and we can NOT push to it. No
#'   `upstream`.
#' * fork: `origin` exists and we can push to it. `origin` is a fork of the repo
#'   configured as `upstream`. We may or may not be able to push to `upstream`.
#' * fork_no_upstream: `origin` exists and we can push to it. `origin` is a
#'   fork, but that parent repo has not (yet) been configured as the
#'   `upstream` remote.
#'
#' Possible GitHub remote configurations, the peculiar ones:
#' * upstream_only: `upstream` exists but `origin` does not.
#' * fork_origin_read_only: `origin` exists, it's a fork, but we can't push to
#'   `origin`. `upstream` may or may not be configured.
#' * fork_upstream_is_not_origin_parent: `origin` exists, it's a fork of
#'   something, `upstream` exists, but `origin` is not a fork of `upstream`.
#' * upstream_but_origin_is_not_fork: `origin` and `upstream` both exist, but
#'   `origin` is not a fork of anything and, specifically, it's not a fork of
#'   `upstream`.
#'
#' @inheritParams use_github
#' @keywords internal
#' @noRd
classify_github_setup <- function(auth_token = github_token(),
                                  host = "https://api.github.com") {
  cfg <- new_github_config()
  grl <- github_remotes2(auth_token = auth_token, host = host)

  if (nrow(grl) == 0) {
    return(cfg_no_github(cfg))
  }

  cfg$origin$is_configured   <- "origin"   %in% grl$remote
  cfg$upstream$is_configured <- "upstream" %in% grl$remote

  make_spec <- function(owner = NA, repo = NA) {
    if (is.na(owner) || is.na(repo)) {
      NA_character_
    } else {
      glue("{owner}/{repo}")
    }
  }

  if (cfg$origin$is_configured) {
    cfg$origin$name <- "origin"
    cols <- intersect(names(grl), names(cfg$origin))
    origin <- grl[grl$remote == "origin", cols]
    cfg$origin <- utils::modifyList(cfg$origin, origin)
    cfg$origin$repo_spec <- with(cfg$origin, make_spec(repo_owner, repo_name))
    cfg$origin$parent_repo_spec <-
      with(cfg$origin, make_spec(parent_repo_owner, parent_repo_name))
  }

  if (cfg$upstream$is_configured) {
    cfg$upstream$name <- "upstream"
    cols <- intersect(names(grl), names(cfg$upstream))
    upstream <- grl[grl$remote == "upstream", cols]
    cfg$upstream <- utils::modifyList(cfg$upstream, upstream)
    cfg$upstream$repo_spec <- with(cfg$upstream, make_spec(repo_owner, repo_name))
  }

  if (cfg$upstream$is_configured && cfg$origin$is_configured) {
    cfg$origin$parent_is_upstream <- identical(
      cfg$origin$parent_repo_spec,
      cfg$upstream$repo_spec
    )
  }
  # cfg is now fully populated, up to type / unsupported / desc

  # origin only
  if (cfg$origin$is_configured && !cfg$upstream$is_configured) {
    if (cfg$origin$is_fork) {
      if (cfg$origin$can_push) {
        return(cfg_fork_no_upstream(cfg))
      } else {
        return(cfg_fork_origin_read_only(cfg))
      }
    } else {
      if (cfg$origin$can_push) {
        return(cfg_ours(cfg))
      } else {
        return(cfg_theirs(cfg))
      }
    }
  }

  # upstream only
  if (!cfg$origin$is_configured && cfg$upstream$is_configured) {
    return(cfg_upstream_only(cfg))
  }

  # origin and upstream
  if (cfg$origin$is_fork) {
    if (cfg$origin$can_push) {
      if (cfg$origin$parent_is_upstream) {
        return(cfg_fork(cfg))
      } else {
        return(cfg_fork_upstream_is_not_origin_parent(cfg))
      }
    } else {
      return(cfg_fork_origin_read_only(cfg))
    }
  } else {
    return(cfg_upstream_but_origin_is_not_fork(cfg))
  }
}

new_github_config <- function() {
  structure(
    list(
      type = NA_character_,
      unsupported = TRUE,
      desc = "Unexpected remote configuration.",
      origin = list(
        name = "origin",
        is_configured = FALSE,
        url = NA_character_,
        can_push = NA,
        repo_owner = NA_character_,
        repo_name = NA_character_,
        repo_spec = NA_character_,
        is_fork = NA,
        can_push_to_parent = NA,
        parent_is_upstream = NA,
        parent_repo_owner = NA_character_,
        parent_repo_name = NA_character_,
        parent_repo_spec = NA_character_
      ),
      upstream = list(
        name = "upstream",
        is_configured = FALSE,
        url = NA_character_,
        can_push = NA,
        repo_owner = NA_character_,
        repo_name = NA_character_,
        repo_spec = NA_character_
      )
    ),
    class = "github_config"
  )
}

#' @export
format.github_config <- function(x, ...) {
  effective_spec <- function(remote) {
    if (remote$is_configured) {
      ui_value(remote$repo_spec)
    } else {
      crayon::silver("<not configured>")
    }
  }
  push_clause <- function(remote) {
    if (remote$is_configured) {
      if (remote$can_push) " (can push)" else " (can not push)"
    }
  }

  origin_push <-
  origin_lines <- c(
    "origin = ", effective_spec(x$origin), push_clause(x$origin),
    if (isTRUE(x$origin$is_fork)) {
      glue(" = fork of {ui_value(x$origin$parent_repo_spec)}")
    }
  )
  upstream_lines <- c(
    "upstream = ", effective_spec(x$upstream), push_clause(x$upstream)
  )
  c(
    glue("GitHub remote configuration = {ui_value(x$type)}"),
    glue("supported = {!x$unsupported}"),
    glue_collapse(origin_lines),
    glue_collapse(upstream_lines),
    if (!is.na(x$desc)) glue("Notes: {x$desc}")
  )
}

#' @export
print.github_config <- function(x, ...) {
  cat(format(x), sep = "\n")
}

#' @export
conditionMessage.usethis_error_bad_github_config <- function(cnd) {
  glue::glue_data(
    cnd$cfg,
    "Unsupported GitHub remote configuration: {desc}"
  )
}

stop_bad_github_config <- function(cfg) {
  abort(
    class = c("usethis_error_bad_github_config", "usethis_error"),
    cfg = cfg
  )
}

## common configurations ----
cfg_no_github <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "no_github",
      unsupported = TRUE,
      desc = glue("
        Neither {ui_value('origin')} nor {ui_value('upstream')} is a GitHub \\
        repo.
        ")
    )
  )
}

cfg_ours <- function(cfg) {
  utils::modifyList(cfg, list(type = "ours", unsupported = FALSE, desc = NA))
}

cfg_theirs <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "theirs",
      unsupported = FALSE,
      desc = glue("
        The only configured GitHub remote is {ui_value('origin')}, which you \\
        cannot push to. Did you mean to create a fork?
        ")
    )
  )
}

cfg_fork <- function(cfg) {
  utils::modifyList(cfg, list(type = "fork", unsupported = FALSE, desc = NA))
}

cfg_fork_no_upstream <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork_no_upstream",
      unsupported = FALSE, # I'm ambivalent about this. We CAN do some things in
                           # this situation, but it's dysfunctional long-term,
                           # because we won't be able to pull from upstream.
      desc = glue("
        {ui_value('origin')} is a fork, but its parent repo is not configured \\
        as the {ui_value('upstream')} remote. This means you cannot pull \\
        changes from {ui_value('upstream')}.
        ")
    )
  )
}

## peculiar configurations ----
cfg_fork_origin_read_only <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork_origin_read_only",
      unsupported = TRUE, # I'm ambivalent about this, I suppose we could view
                          # this as an unusual version of "theirs"? We do
                          # actually know the parent repo, so it's possible to
                          # do some local work. But then we can't push it.
      desc = glue("
        The {ui_value('origin')} remote is a fork, but you can't push to it.
        ")
    )
  )
}

cfg_upstream_only <- function(cfg) {
  utils::modifyList(
    cfg,
    type = "upstream_only",
    unsupported = TRUE, # I'm ambivalent about this. If we can push, this could
                        # be regarded as yet another look for "ours". If we
                        # can't push, this could be regarded as variant of
                        # "theirs".
    desc = glue("
      The only GitHub remote is {ui_value('upstream')}.
      usethis expects {ui_value('origin')} or both {ui_value('origin')} and \\
      {ui_value('upstream')} to be configured.
      ")
  )
}

cfg_fork_upstream_is_not_origin_parent <- function(cfg) {
  utils::modifyList(
    cfg,
    type = "fork_upstream_is_not_origin_parent",
    unsupported = TRUE,
    desc = glue("
      The {ui_value('origin')} GitHub remote is a fork, but it's not a fork \\
      of the repo configured as the {ui_value('upstream')} remote.
      ")
  )
}

cfg_upstream_but_origin_is_not_fork <- function(cfg) {
  utils::modifyList(
    cfg,
    type = "upstream_but_origin_is_not_fork",
    unsupported = TRUE,
    desc = glue("
      Both {ui_value('origin')} and {ui_value('upstream')} are GitHub \\
      remotes, but {ui_value('origin')} is not a fork and, in particular, is \\
      not a fork of {ui_value('upstream')}.
      ")
  )
}
