#' Gather data on GitHub-associated remotes
#'
#' Creates a data frame where each row represents a GitHub-associated remote.
#' The data frame is initialized via `gert::git_remote_list()`, possibly
#' filtered for specific remotes, then (optionally) built out with data from the
#' GitHub API.
#'
#' @param these Intersect the list of GitHub-associated remotes with `these`
#'   remote names. To keep all GitHub-associated remotes, use `these = NULL` or
#'   `these = character()`.
#' @param github_get Whether to use the `/repos/:owner/:repo` endpoint of the
#'   GitHub API to get more information about each remote repository, such as
#'   whether it's a fork and whether the user can push. `NA` (the default) means
#'   to add this info if possible. An explicit `TRUE` or `FALSE` is taken
#'   literally. *Not fully implemented yet.*
#' @inheritParams use_github
#' @keywords internal
#' @noRd
github_remotes2 <- function(these = c("origin", "upstream"),
                            github_get = NA,
                            auth_token = github_token(),
                            host = "https://api.github.com") {
  # TODO: Fully implement the behaviour promised for `github_get`:
  # * no internet access
  # * no GITHUB_PAT
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

  if (identical(github_get, FALSE)) {
    return(grl)
  }

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
  # TODO: permission won't be here if we don't have a PAT
  # deal with that
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
#' Some setups are *supported*, meaning usethis can do its job correctly, and
#' others are *unsupported*, meaning usethis can't fulfill the user's request.
#' Some *supported* setups are still considered suboptimal. Here's how I think
#' this will work for any specific usethis function:
#' * `stop_bad_github_config()` for unsupported setups
#' * Use `ui_github_config_wat()` to inform the user about
#'   suboptimal-but-supported setups and give them a chance to back out. The
#'   setups that trigger this may vary from function to function.
#' * Proceed quietly for setups we consider ideal.
#'
#' Possible GitHub remote configurations, the common cases:
#' * no_github: No `origin`, no `upstream`. Unsupported.
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
    cols <- intersect(names(grl), names(cfg$origin))
    origin <- grl[grl$remote == "origin", cols]
    cfg$origin <- utils::modifyList(cfg$origin, origin)
    cfg$origin$repo_spec <- with(cfg$origin, make_spec(repo_owner, repo_name))
    cfg$origin$parent_repo_spec <-
      with(cfg$origin, make_spec(parent_repo_owner, parent_repo_name))
  }

  if (cfg$upstream$is_configured) {
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

#' Get a repo spec
#'
#' Returns an OWNER/REPO repo spec for, e.g., incorporating into a URL.
#' Examples:
#' * Badge URLs
#' * URLs where you can activate a CI service
#' * URLs for URL and BugReports in DESCRIPTION
#'
#' Use this when you suspect the user is doing something in order to make a pull
#' request or if it's not clear if they want to work against their fork or the
#' fork parent. `get_repo_spec()` will challenge "theirs" and "fork_no_upstream"
#' and ask if user wants to back out and fix the remote configuration. In the
#' case of "fork" and "fork_no_upstream", user gets an interactive menu to
#' choose between `origin` and its parent repo (which may or may not be
#' configured as `upstream`).
#'
#' @inheritParams use_github
#' @keywords internal
#' @noRd
get_repo_spec <- function(auth_token = github_token(),
                          host = "https://api.github.com") {
  cfg <- classify_github_setup(auth_token = auth_token, host = host)
  if (cfg$unsupported) {
    stop_bad_github_config(cfg)
  }
  if (cfg$type == "ours") {
    return(cfg$origin$repo_spec)
  }
  if (cfg$type == "theirs") {
    if (ui_github_config_wat(cfg)) {
      ui_stop("Exiting due to unfavorable GitHub config")
    } else {
      return(cfg$origin$repo_spec)
    }
  }
  if (cfg$type == "fork_no_upstream") {
    if (ui_github_config_wat(cfg)) {
      ui_stop("Exiting due to unfavorable GitHub config")
    }
  }
  if (!(cfg$type %in% c("fork", "fork_no_upstream"))) {
    ui_stop("Internal error. Unexpected GitHub config type: {cfg$type}")
  }
  if (!is_interactive()) {
    ui_info("
      Working with a fork, non-interactively. \\
      Targetting the fork parent = {ui_value(cfg$origin$parent_repo_spec)}
      ")
    cfg$origin$parent_repo_spec
  } else {
    choices <- c(
      glue("{cfg$origin$parent_repo_spec} = parent of your fork"),
      glue("{cfg$origin$repo_spec} = your fork")
    )
    title <- glue("
      Working with a fork.
      Which repo should we target?
      ")
    choice <- utils::menu(choices, graphics = FALSE, title = title)
    return(with(cfg$origin, c(parent_repo_spec, repo_spec)[choice]))
  }
}

# Like get_repo_spec(), but do much less. No API calls.
# No full-fledged evaluation of the GitHub remotes. Take them at face value.
get_repo_spec_lite <- function() {
  grl <- github_remotes2(github_get = FALSE)
  if (nrow(grl) < 1) {
    return()
  }
  grl$repo_spec <- glue_data(grl, "{repo_owner}/{repo_name}")
  if (!is_interactive() && nrow(grl) > 1) {
    ui_info("
      Both {ui_value('origin')} and {ui_value('upstream')} are GitHub remotes.
      Using spec for {ui_value('origin')}.")
    return(grl$repo_spec[grl$remote == "origin"])
  }
  if (nrow(grl) == 1) {
    return(grl$repo_spec)
  }
  choice <- utils::menu(
    choices = glue_data(grl, "{repo_spec} ({remote})"),
    graphics = FALSE,
    title = "Which repo should we target?"
  )
  grl$repo_spec[choice]
}

#' Get the spec of the primary repo
#'
#' This is a simplified variant of `get_repo_spec()`. Use it when you're quite
#' sure that you want the primary repo (so fork parent, in the case of a fork),
#' with no nudges or interactive choice.
#'
#' @keywords internal
#' @noRd
get_primary_spec <- function() {
  cfg <- classify_github_setup()
  if (cfg$unsupported) {
    stop_bad_github_config(cfg)
  }
  if (cfg$type %in% c("ours", "theirs")) {
    cfg$origin$repo_spec
  } else if (cfg$type %in% c("fork", "fork_no_upstream")) {
    out <- cfg$origin$parent_repo_spec
    ui_info("Targetting the fork parent = {ui_value(out)}")
    out
  } else {
    ui_stop("Internal error. Unexpected GitHub config type: {cfg$type}")
  }
}

# formatting github remote configurations for humans ---------------------------
format_remote <- function(remote) {
  effective_spec <- function(remote) {
    if (remote$is_configured) {
      ui_value(remote$repo_spec)
    } else {
      ui_unset("not configured")
    }
  }
  push_clause <- function(remote) {
    if (remote$is_configured) {
      if (remote$can_push) " (can push)" else " (can not push)"
    }
  }
  out <- c(
    glue("{remote$name} = {effective_spec(remote)}"),
    push_clause(remote),
    if (isTRUE(remote$is_fork)) {
      glue(" = fork of {ui_value(remote$parent_repo_spec)}")
    }
  )
  glue_collapse(out)
}

format_fields <- function(cfg) {
  list(
    type = glue("type = {ui_value(cfg$type)}"),
    unsupported = glue("unsupported = {ui_value(cfg$unsupported)}"),
    origin = format_remote(cfg$origin),
    upstream = format_remote(cfg$upstream),
    desc = if (is.na(cfg$desc)) {
      glue("desc = {ui_unset('no description')}")
    } else {
      glue("desc = {cfg$desc}")
    }
  )
}

#' @export
format.github_config <- function(x, ...) {
  glue::as_glue(format_fields(x))
}

#' @export
print.github_config <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

# refines output of format_fields() to create input better suited to
# ui_github_config_wat() and stop_bad_github_config()
github_config_wat <- function(cfg, context = c("menu", "abort")) {
  context <- match.arg(context)
  adjective <- switch(context, menu = "Unexpected", abort = "Unsupported")
  out <- format_fields(cfg)
  out$unsupported <- NULL
  out$type <- glue("{adjective} GitHub remote configuration: {ui_value(cfg$type)}")
  out$desc <- if (is.na(cfg$desc)) NULL else cfg$desc
  out
}

# returns TRUE if user selects "no" --> exit the calling function
# return FALSE if user select "yes" --> keep going, they've been warned
ui_github_config_wat <- function(cfg) {
  ui_nope(
    github_config_wat(cfg, context = "menu"),
    yes = "Yes, I want to proceed. I know what I'm doing.",
    no = "No, I want to stop and straighten out my GitHub remotes first.",
    n_yes = 1, n_no = 1, shuffle = FALSE
  )
}

stop_bad_github_config <- function(cfg) {
  abort(
    message = unname(github_config_wat(cfg, context = "abort")),
    class = c("usethis_error_bad_github_config", "usethis_error"),
    cfg = cfg
  )
}

stop_unsupported_pr_config <- function(cfg) {
  msg <- github_config_wat(cfg)
  msg$type <- glue("
    Pull request functions can't work with GitHub remote configuration: \\
    {ui_value(cfg$type)}
    ")
  abort(
    message = unname(msg),
    class = c("usethis_error_invalid_pr_config", "usethis_error"),
    cfg = cfg
  )
}

# common configurations --------------------------------------------------------
cfg_no_github <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "no_github",
      unsupported = TRUE,
      desc = glue("
        Neither {ui_value('origin')} nor {ui_value('upstream')} is a GitHub \\
        repo.")
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
        cannot push to.
        If your goal is to make a pull request, you must \\
        fork-and-clone.
        {ui_code('usethis::create_from_github()')} can do this.
        ")
    )
  )
}

cfg_fork <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork",
      unsupported = FALSE,
      # TODO: say whether user can push to parent / upstream?
      desc = glue("
        {ui_value('origin')} is a fork of {ui_value(cfg$upstream$repo_spec)}, \\
        which is configured as the {ui_value('upstream')} remote.
        ")
    ))
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
        {ui_value('origin')} is a fork, but its parent is not configured \\
        as {ui_value('upstream')}.
        You can make a pull request.
        However, going forward, you can't pull changes from the main repo.
        Use {ui_code('usethis::use_git_remote()')} to add the parent repo as \\
        the {ui_value('upstream')} remote.
        ")
    )
  )
}

# peculiar configurations ------------------------------------------------------
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
