github_login <- function(auth_token, host = "https://github.com") {
  out <- gh::gh_whoami(.token = auth_token, .api_url = host)
  out$login
}

# repo_spec --> owner, repo
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    ui_stop("{ui_code('repo_spec')} must be of form {ui_value('owner/repo')}.")
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo

# owner, repo --> repo_spec
make_spec <- function(owner = NA, repo = NA) {
  no_spec <- is.na(owner) | is.na(repo)
  as.character(ifelse(no_spec, NA, glue("{owner}/{repo}")))
}

# named vector or list of GitHub URLs --> data frame of URL parts
# more general than the name suggests
# definitely designed for GitHub URLs but not overtly GitHub-specific
# https://stackoverflow.com/questions/2514859/regular-expression-for-git-repository
# https://git-scm.com/docs/git-clone#_git_urls
# https://stackoverflow.com/questions/27745/getting-parts-of-a-url-regex
parse_github_remotes <- function(x) {
  # https://github.com/r-lib/usethis
  #                                    --> https, github.com,      rlib, usethis
  # https://github.com/r-lib/usethis.git
  #                                    --> https, github.com,      rlib, usethis
  # https://github.com/r-lib/usethis#readme
  #                                    --> https, github.com,      rlib, usethis
  # https://github.com/r-lib/usethis/issues/1169
  #                                    --> https, github.com,      rlib, usethis
  # https://github.acme.com/r-lib/devtools.git
  #                                    --> https, github.acme.com, rlib, usethis
  # git@github.com:r-lib/usethis.git
  #                                    --> ssh,   github.com,      rlib, usethis
  re <- paste0(
    "^",
    "(?<prefix>git|ssh|http[s]?)",
    "[:/@]+",
    "(?<host>[^/:]+)",
    "[/:]",
    "(?<repo_owner>[^/]+)",
    "/",
    "(?<repo_name>[^/#]+)",
    "(?<fragment>.*)",
    "$"
  )
  dat <- rematch2::re_match(x, re)
  dat$url <- dat$.text
  # as.character() necessary for edge case of length-0 input
  dat$protocol <- as.character(ifelse(dat$prefix == "https", "https", "ssh"))
  dat$name <- if (rlang::is_named(x)) names(x) else NA_character_
  dat$repo_name <- sub("[.]git$", "", dat$repo_name)
  dat[c("name", "url", "host", "repo_owner", "repo_name", "protocol")]
}

github_remote_from_description <- function(desc) {
  stopifnot(inherits(desc, "description"))
  urls <- c(
    desc$get_field("BugReports", default = character()),
    desc$get_urls()
  )
  gh_links <- grep("^https?://github.com/", urls, value = TRUE)
  if (length(gh_links) > 0) {
    parsed <- parse_github_remotes(gh_links[[1]])
    as.list(parsed[c("repo_owner", "repo_name")])
  }
}

#' Attempt to get a PAT from gitcreds
#'
#' Asks gitcreds for a PAT corresponding to a URL. If there is no such PAT,
#' returns `""`. All other errors are thrown. But maybe we should also not error
#' for "no git"? Main difference from `gitcreds::gitcreds_get()` is that we
#' catch "no creds". Main difference between `gitcreds::gitcreds_get()` and `git
#' credential fill` is lack of forced user interactivity, i.e. it's possible to
#' simply not get a PAT, without throwing an error.
#'
#' @param url URL that gitcreds ultimately passes to `git credential fill`
#' @keywords internal
#' @noRd
gitcreds_token <- function(url = "https://github.com") {
  credential <- tryCatch(
    gitcreds::gitcreds_get(url),
    gitcreds_nogit_error = function(e) stop("no_git"),
    gitcreds_no_credentials = function(e) NULL
  )
  credential$password %||% ""
}

#' Gather LOCAL data on GitHub-associated remotes
#'
#' Creates a data frame where each row represents a GitHub-associated remote.
#' The data frame is initialized via `gert::git_remote_list()`, possibly
#' filtered for specific remote names. The remote URLs are parsed into parts,
#' like `host` and `repo_owner`. This is filtered again for rows where the
#' `host` appears to be a GitHub deployment (currently a crude search for
#' "github"). Some of these parts are recombined or embellished to get new
#' columns (`host_url`, `api_url`, `repo_spec`). All operations are entirely
#' mechanical and local.
#'
#' @param these Intersect the list of remotes with `these` remote names. To keep
#'   all remotes, use `these = NULL` or `these = character()`.
#' @param x Data frame with character columns `name` and `url`. Exposed as an
#'   argument for internal reasons. It's so we can call the functions that
#'   marshal info about GitHub remotes with 0-row input to obtain a properly
#'   typed template without needing a Git repo or calling GitHub. We just want
#'   to get a data frame with zero rows, but with the column names and types
#'   implicit in our logic.
#' @keywords internal
#' @noRd
github_remote_list <- function(these = c("origin", "upstream"), x = NULL) {
  x <- x %||% gert::git_remote_list(repo = git_repo())
  stopifnot(is.null(these) || is.character(these))
  stopifnot(is.data.frame(x), is.character(x$name), is.character(x$url))
  if (length(these) > 0) {
    x <- x[x$name %in% these, ]
  }

  parsed <- parse_github_remotes(set_names(x$url, x$name))
  # TODO: generalize here for GHE hosts that don't include 'github'
  is_github <- grepl("github", parsed$host)
  parsed <- parsed[is_github, ]

  parsed$remote <- parsed$name
  parsed$host_url <- as.character(glue("https://{parsed$host}"))
  # TODO: get rid of this `:::` use of gh
  parsed$api_url <- map_chr(parsed$host_url, gh:::get_apiurl)
  parsed$repo_spec <- make_spec(parsed$repo_owner, parsed$repo_name)

  parsed[c(
    "remote",
    "url", "host_url", "api_url", "host", "protocol",
    "repo_owner", "repo_name", "repo_spec"
  )]
}

#' Gather LOCAL and REMOTE data on GitHub-associated remotes
#'
#' Creates a data frame where each row represents a GitHub-associated remote,
#' starting with the output of `github_remote_list()` (local data). This
#' function's job is to (try to) add information we can only retrieve from the
#' GitHub API. Key jobs:
#' * Attempt to get a token from gitcreds based on the host URL.
#' * We explicitly get a token, for now at least, even though we could just let
#'   gh handle token discovery. This is so we can better understand why the
#'   GitHub API call may not have succeeded. This is useful for development and
#'   probably also for user-facing advice.
#' * Use gh, with our token and API URL, for GET /repos/:owner/:repo.
#' * Massage the resulting data into our data frame.
#'
#' @inheritParams github_remote_list
#' @keywords internal
#' @noRd
github_remotes <- function(these = c("origin", "upstream"), x = NULL) {
  grl <- github_remote_list(these = these, x = x)
  grl$token <- map_chr(grl$host_url, gitcreds_token)

  get_gh_repo <- function(repo_owner, repo_name,
                          token = "", api_url = "https://api.github.com") {
    purrr::possibly(gh::gh, otherwise = list())(
      "GET /repos/:owner/:repo",
      owner = repo_owner, repo = repo_name,
      .token = token, .api_url = api_url
    )
  }

  repo_info <- purrr::pmap(
    grl[c("repo_owner", "repo_name", "token", "api_url")],
    get_gh_repo
  )
  grl$have_github_info <- map_lgl(repo_info, ~ length(.x) > 0)

  grl$is_fork <- map_lgl(repo_info, "fork", .default = NA)
  # `permissions` is an example of data that is not present if the request
  # did not include a PAT
  grl$can_push <- map_lgl(repo_info, c("permissions", "push"), .default = NA)
  grl$parent_repo_owner <-
    map_chr(repo_info, c("parent", "owner", "login"), .default = NA)
  grl$parent_repo_name <-
    map_chr(repo_info, c("parent", "name"), .default = NA)
  grl$parent_repo_spec <-  make_spec(grl$parent_repo_owner, grl$parent_repo_name)

  parent_info <- purrr::pmap(
    set_names(
      grl[c("parent_repo_owner", "parent_repo_name", "token", "api_url")],
      ~ sub("parent_", "", .x)
    ),
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
#' other downstream functions can decide whether to proceed / abort / complain &
#' offer to fix.
#' We only consider the remotes where:
#' * Name is `origin` or `upstream` and the remote URL "looks like github"
#'   (github.com or a GHE deployment)
#'
#' We have to call the GitHub API to fully characterize the GitHub remote
#' situation. That's the only way to learn if the user can push to a remote,
#' whether a remote is a fork, and which repo is the parent of a fork.
#' `github_get` controls whether we make these API calls.
#'
#' Some functions can get by with the information that's available locally, i.e.
#' we can use simple logic to decide whether to target `origin` or `upstream` or
#' present the user with a choice. We can set `github_get = FALSE` in this case.
#' Other functions, like the `pr_*()` functions, are more demanding and we'll
#' always determine the config with `github_get = TRUE`.
#'
#' Here's how a usethis function can use the GitHub remote configuration:
#' * `cfg <- classify_github_config(...)`
#' * Inspect `cfg$type` and call `stop_bad_github_remote_config()` if the
#'   function can't work with that config.
#' * If the config is suboptimal-but-supported, use
#'   `ui_github_remote_config_wat()` to educate the user and give them a chance
#'   to back out.
#' * Proceed quietly if the config is OK.
#'
#' Fields in an instance of `github_remote_config`:
#' * `type`: explained below
#' * `pr_ready`: Logical. Do the `pr_*()` functions support it?
#' * `desc`: A description used in messages and menus.
#' * `origin`: Information about the `origin` GitHub remote.
#' * `upstream`: Information about the `origin` GitHub remote.
#'
#' Possible GitHub remote configurations, the common cases:
#' * no_github: No `origin`, no `upstream`.
#' * ours: `origin` exists, is not a fork, and we can push to it. Owner of
#'   `origin` could be current user, another user, or an org. No `upstream`.
#'   - Less common variant: `upstream` exists, `origin` does not, and we can
#'     push to `upstream`. The fork-ness of `upstream` is not consulted.
#' * fork: `origin` exists and we can push to it. `origin` is a fork of the repo
#'   configured as `upstream`. We may or may not be able to push to `upstream`.
#' * theirs: Exactly one of `origin` and `upstream` exist and we can't push to
#'   it. The fork-ness of this remote repo is not consulted.
#'
#' Possible GitHub remote configurations, the peculiar ones:
#' * fork_upstream_is_not_origin_parent: `origin` exists, it's a fork, but its
#'   parent repo is not configured as `upstream`. Either there's no `upstream`
#'   or `upstream` exists but it's not the parent of `origin`.
#' * fork_cannot_push_origin: `origin` is a fork and its parent is configured
#'   as `upstream`. But we can't push to `origin`.
#' * upstream_but_origin_is_not_fork: `origin` and `upstream` both exist, but
#'   `origin` is not a fork of anything and, specifically, it's not a fork of
#'   `upstream`.
#'
#'  Remote configuration "guesses" we apply when `github_get = FALSE`:
#'  * maybe_ours_or_theirs: Exactly one of `origin` and `upstream` exists.
#'  * maybe_fork: Both `origin` and `upstream` exist.
#'
#' @inheritParams github_remotes
#' @keywords internal
#' @noRd
new_github_remote_config <- function() {
  ptype <- github_remotes(
    x = data.frame(name = character(), url = character(), stringsAsFactors = FALSE)
  )
  # 0-row df --> a well-named list of properly typed NAs
  ptype <- map(ptype, ~ c(NA, .x))
  structure(
    list(
      type = NA_character_,
      pr_ready = FALSE,
      desc = "Unexpected remote configuration.",
      origin   = c(name = "origin",   is_configured = FALSE, ptype),
      upstream = c(name = "upstream", is_configured = FALSE, ptype)
    ),
    class = "github_remote_config"
  )
}

github_remote_config <- function(github_get = TRUE) {
  cfg <- new_github_remote_config()
  if (github_get) {
    grl <- github_remotes()
  } else {
    grl <- github_remote_list()
    grl$have_github_info <- FALSE
  }

  if (nrow(grl) == 0) {
    return(cfg_no_github(cfg))
  }

  cfg$origin$is_configured   <- "origin"   %in% grl$remote
  cfg$upstream$is_configured <- "upstream" %in% grl$remote

  single_remote <- xor(cfg$origin$is_configured, cfg$upstream$is_configured)

  # check that hosts match
  # remember: anyDuplicated() returns an index, NOT logical
  if (!single_remote && anyDuplicated(grl$host) < 1) {
    # example: github.com and github.acme.com
    ui_stop("
      Unsupported GitHub remote configuration: mismatched hosts
          origin = {grl$host[grl$remote == 'origin']}
        upstream = {grl$host[grl$remote == 'upstream']}")
  }

  # check we've got GitHub info for all remotes or for none
  if (!single_remote && anyDuplicated(grl$have_github_info) < 1) {
    tmp_o <- grl[grl$remote == "origin", c("url", "have_github_info")]
    tmp_u <- grl[grl$remote == "upstream", c("url", "have_github_info")]
    ui_stop("
      Unsupported GitHub remote configuration: incomplete GitHub information
        origin ({tmp_o$url}), GitHub info: {tmp_o$have_github_info}
        upstream ({tmp_u$url}), GitHub info: {tmp_u$have_github_info}")
  }
  have_github_info <- any(grl$have_github_info)

  if (cfg$origin$is_configured) {
    cfg$origin <-
      utils::modifyList(cfg$origin, grl[grl$remote == "origin",])
  }

  if (cfg$upstream$is_configured) {
    cfg$upstream <-
      utils::modifyList(cfg$upstream, grl[grl$remote == "upstream",])
  }

  if (!have_github_info) {
    if (single_remote) {
      return(cfg_maybe_ours_or_theirs(cfg))
    } else {
      return(cfg_maybe_fork(cfg))
    }
  }
  # `have_github_info` must be TRUE

  if (!single_remote) {
    cfg$origin$parent_is_upstream <-
      identical(cfg$origin$parent_repo_spec, cfg$upstream$repo_spec)
  }

  # origin only
  if (single_remote && cfg$origin$is_configured) {
    if (cfg$origin$is_fork) {
      if (cfg$origin$can_push) {
        return(cfg_fork_upstream_is_not_origin_parent(cfg))
      } else {
        return(cfg_theirs(cfg))
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
  if (single_remote && cfg$upstream$is_configured) {
    if (cfg$upstream$can_push) {
      return(cfg_ours(cfg))
    } else {
      return(cfg_theirs(cfg))
    }
  }

  # origin and upstream
  if (cfg$origin$is_fork) {
    if (cfg$origin$parent_is_upstream) {
      if (cfg$origin$can_push) {
        return(cfg_fork(cfg))
      } else {
        return(cfg_fork_cannot_push_origin(cfg))
      }
    } else {
      return(cfg_fork_upstream_is_not_origin_parent(cfg))
    }
  } else {
    return(cfg_upstream_but_origin_is_not_fork(cfg))
  }
}

#' Select a target (GitHub) repo
#'
#' @description
#' Returns information about a GitHub repository. Used when we need to designate
#' which repo we will, e.g., open an issue on or activate a CI service for.
#' This information might be used in a GitHub API request or to form URLs.
#'
#' Examples:
#' * Badge URLs
#' * URLs where you can activate a CI service
#' * URLs for DESCRIPTION fields such as URL and BugReports
#'
#' If `cfg` is not provided, `target_repo()` calls
#' `github_remote_config(github_get = FALSE)` and works only with locally
#' available information about GitHub remotes. To work with full GitHub remote
#' configuration, call `github_remote_config(github_get = TRUE)` yourself and
#' pass the resulting `cfg` in. `target_repo()` will challenge certain configs,
#' e.g., "fork_upstream_is_not_origin_parent", and ask if user wants to back out
#' and fix the remote configuration.
#'
#' In some configurations, if `ask = TRUE` and we're in an interactive session,
#' user gets a choice between `origin` and (if either exists or is known) its
#' parent repo and `upstream`.
#'
#' We use "source" to mean the principal repo where a project's development
#' happens. We use "primary" to mean the principal repo this particular user
#' interacts with or has the greatest power over. They can be the same or
#' different. Examples:
#' * For a personal project you own, "source" and "primary" are the same.
#'   Presumably the `origin` remote.
#' * For a collaboratively developed project, an outside contributor must create
#'   a fork in order to make a PR. For such a person, their fork is "primary"
#'   (presumably `origin`) and the original repo that they forked is "source"
#'   (presumably `upstream`).
#'
#' This is *almost* consistent with terminology used by the GitHub API. A fork
#' has a "source repo" and a "parent repo", which are usually the same. They
#' only differ when working with a fork of a repo that is itself a fork. In this
#' rare case, the parent is the immediate fork parent and the source is the
#' ur-parent, i.e. the root of this particular tree. The source repo is not a
#' fork.
#'
#' @inheritParams use_github
#' @keywords internal
#' @noRd
target_repo <- function(cfg = NULL,
                        role = c("source", "primary"),
                        ask = is_interactive()) {
  cfg <- cfg %||% github_remote_config(github_get = FALSE)
  stopifnot(inherits(cfg, "github_remote_config"))
  role <- match.arg(role)

  bad_configs <- c(
    "no_github",
    "fork_upstream_is_not_origin_parent",
    "fork_cannot_push_origin",
    "upstream_but_origin_is_not_fork"
  )
  if (cfg$type %in% bad_configs) {
    stop_bad_github_remote_config(cfg)
  }

  # upstream only
  if (cfg$upstream$is_configured && !cfg$origin$is_configured) {
    return(cfg$upstream)
  }

  # origin only
  if (cfg$origin$is_configured && !cfg$upstream$is_configured) {
    return(cfg$origin)
  }

  if (!ask || !is_interactive()) {
    return(switch(
      role,
      source  = cfg$upstream,
      primary = cfg$origin
    ))
  }

  choices <- c(
    origin   = glue("{cfg$origin$repo_spec} = {ui_value('origin')}"),
    upstream = glue("{cfg$upstream$repo_spec} = {ui_value('upstream')}")
  )
  title <- glue("Which repo should we target?")
  choice <- utils::menu(choices, graphics = FALSE, title = title)
  cfg[[names(choices)[choice]]]
}

target_repo_spec <- function(role = c("source", "primary"),
                             ask = is_interactive()) {
  tr <- target_repo(role = match.arg(role), ask = ask)
  tr$repo_spec
}

# `x` is probably the return value of `target_repo()`
check_have_github_info <- function(x) {
  if (x$have_github_info) {
    return(invisible())
  }
  get_code <- glue("gitcreds::gitcreds_get(\"{x$host_url}\")")
  set_code <- glue("gitcreds::gitcreds_set(\"{x$host_url}\")")
  ui_stop("
      Unable to discover a token for {ui_value(x$host_url)}
        Call {ui_code(get_code)} to experience this first-hand
        Call {ui_code(set_code)} to store a token")
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
    if (!remote$is_configured || is.na(remote$can_push)) {
      return()
    }
    if (remote$can_push) " (can push)" else " (can not push)"
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
    pr_ready = glue("Config supports a pull request = {ui_value(cfg$pr_ready)}"),
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
format.github_remote_config <- function(x, ...) {
  glue::as_glue(format_fields(x))
}

#' @export
print.github_remote_config <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

# refines output of format_fields() to create input better suited to
# ui_github_remote_config_wat() and stop_bad_github_remote_config()
github_remote_config_wat <- function(cfg, context = c("menu", "abort")) {
  context <- match.arg(context)
  adjective <- switch(context, menu = "Unexpected", abort = "Unsupported")
  out <- format_fields(cfg)
  out$pr_ready <- NULL
  out$type <- glue("{adjective} GitHub remote configuration: {ui_value(cfg$type)}")
  out$desc <- if (is.na(cfg$desc)) NULL else cfg$desc
  out
}

# returns TRUE if user selects "no" --> exit the calling function
# return FALSE if user select "yes" --> keep going, they've been warned
ui_github_remote_config_wat <- function(cfg) {
  ui_nope(
    github_remote_config_wat(cfg, context = "menu"),
    yes = "Yes, I want to proceed. I know what I'm doing.",
    no = "No, I want to stop and straighten out my GitHub remotes first.",
    shuffle = FALSE
  )
}

stop_bad_github_remote_config <- function(cfg) {
  abort(
    message = unname(github_remote_config_wat(cfg, context = "abort")),
    class = c("usethis_error_bad_github_remote_config", "usethis_error"),
    cfg = cfg
  )
}

stop_unsupported_pr_config <- function(cfg) {
  msg <- github_remote_config_wat(cfg)
  msg$type <- glue("
    Pull request functions can't work with GitHub remote configuration: \\
    {ui_value(cfg$type)}")
  abort(
    message = unname(msg),
    class = c("usethis_error_invalid_pr_config", "usethis_error"),
    cfg = cfg
  )
}

# github remote configurations -------------------------------------------------
cfg_no_github <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "no_github",
      pr_ready = FALSE,
      desc = glue("
        Neither {ui_value('origin')} nor {ui_value('upstream')} is a GitHub \\
        repo.")
    )
  )
}

cfg_ours <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "ours",
      pr_ready = TRUE,
      desc = NA)
  )
}

cfg_theirs <- function(cfg) {
  configured <- if (cfg$origin$is_configured) "origin" else "upstream"
  utils::modifyList(
    cfg,
    list(
      type = "theirs",
      pr_ready = FALSE,
      desc = glue("
        The only configured GitHub remote is {ui_value(configured)}, which
        you cannot push to.
        If your goal is to make a pull request, you must fork-and-clone.
        {ui_code('usethis::create_from_github()')} can do this.")
    )
  )
}

cfg_maybe_ours_or_theirs <- function(cfg) {
  if (cfg$origin$is_configured) {
    configured <- "origin"
    not_configured <- "upstream"
  } else {
    configured <- "upstream"
    not_configured <- "origin"
  }
  utils::modifyList(
    cfg,
    list(
      type = "maybe_ours_or_theirs",
      pr_ready = NA,
      desc = glue("
        {ui_value(configured)} is a GitHub repo and {ui_value(not_configured)} \\
        is either not configured or is not a GitHub repo.")
    )
  )
}

cfg_fork <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork",
      pr_ready = TRUE,
      # TODO: say whether user can push to parent / upstream?
      desc = glue("
        {ui_value('origin')} is a fork of {ui_value(cfg$upstream$repo_spec)}, \\
        which is configured as the {ui_value('upstream')} remote.")
    )
  )
}

cfg_maybe_fork <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "maybe_fork",
      pr_ready = NA,
      desc = glue("
        Both {ui_value('origin')} and {ui_value('upstream')} appear to be \\
        GitHub repos.")
    )
  )
}

cfg_fork_cannot_push_origin <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork_cannot_push_origin",
      pr_ready = FALSE,
      desc = glue("
        The {ui_value('origin')} remote is a fork, but you can't push to it.")
    )
  )
}

cfg_fork_upstream_is_not_origin_parent <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork_upstream_is_not_origin_parent",
      pr_ready = FALSE,
      desc = glue("
        The {ui_value('origin')} GitHub remote is a fork, but its parent is \\
        not configured as the {ui_value('upstream')} remote.")
    )
  )
}

cfg_upstream_but_origin_is_not_fork <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "upstream_but_origin_is_not_fork",
      pr_ready = FALSE,
      desc = glue("
        Both {ui_value('origin')} and {ui_value('upstream')} are GitHub \\
        remotes, but {ui_value('origin')} is not a fork and, in particular, \\
        is not a fork of {ui_value('upstream')}.")
    )
  )
}
