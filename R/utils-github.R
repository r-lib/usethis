# OWNER/REPO --> OWNER, REPO
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    ui_stop("{ui_code('repo_spec')} must be of form {ui_value('owner/repo')}.")
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo

# OWNER, REPO --> OWNER/REPO
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
github_remote_regex <- paste0(
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
  dat <- re_match(x, github_remote_regex)
  dat$url <- dat$.text
  # as.character() necessary for edge case of length-0 input
  dat$protocol <- as.character(ifelse(dat$prefix == "https", "https", "ssh"))
  dat$name <- if (rlang::is_named(x)) {
    names(x)
  } else {
    rep_len(NA_character_, length.out = nrow(dat))
  }
  dat$repo_name <- sub("[.]git$", "", dat$repo_name)
  dat[c("name", "url", "host", "repo_owner", "repo_name", "protocol")]
}

parse_repo_url <- function(x) {
  stopifnot(is_string(x))
  dat <- re_match(x, github_remote_regex)
  if (is.na(dat$.match)) {
    list(repo_spec = x, host = NULL)
  } else {
    dat <- parse_github_remotes(x)
    # TODO: generalize here for GHE hosts that don't include 'github'
    if (!grepl("github", dat$host)) {
      ui_stop("URL doesn't seem to be associated with GitHub: {ui_value(x)}")
    }
    list(
      repo_spec = make_spec(owner = dat$repo_owner, repo = dat$repo_name),
      host = glue("https://{dat$host}")
    )
  }
}

github_url_from_git_remotes <- function() {
  tr <- tryCatch(target_repo(github_get = NA), error = function(e) NULL)
  if (is.null(tr)) {
    return()
  }
  parsed <- parse_github_remotes(tr$url)
  glue_data_chr(parsed, "https://{host}/{repo_owner}/{repo_name}")
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
  parsed$host_url <- glue_chr("https://{parsed$host}")
  parsed$api_url <- map_chr(parsed$host_url, get_apiurl)
  parsed$repo_spec <- make_spec(parsed$repo_owner, parsed$repo_name)

  parsed[c(
    "remote",
    "url", "host_url", "api_url", "host", "protocol",
    "repo_owner", "repo_name", "repo_spec"
  )]
}

#' Gather LOCAL and (maybe) REMOTE data on GitHub-associated remotes
#'
#' Creates a data frame where each row represents a GitHub-associated remote,
#' starting with the output of `github_remote_list()` (local data). This
#' function's job is to (maybe) add information we can only get from the GitHub
#' API. If `github_get = FALSE`, we don't even attempt to call the API.
#' Otherwise, we try and will succeed if gh discovers a suitable token. The
#' resulting data, even if the API data is absent, is massaged into a data
#' frame.
#'
#' @inheritParams github_remote_list
#' @param github_get Whether to attempt to get repo info from the GitHub API. We
#'   try for `NA` (the default) and `TRUE`. If we aren't successful, we proceed
#'   anyway for `NA` but error for `TRUE`. When `FALSE`, no attempt is made to
#'   call the API.
#' @keywords internal
#' @noRd
github_remotes <- function(these = c("origin", "upstream"),
                           github_get = NA,
                           x = NULL) {
  grl <- github_remote_list(these = these, x = x)
  get_gh_repo <- function(repo_owner, repo_name,
                          api_url = "https://api.github.com") {
    if (isFALSE(github_get)) {
      f <- function(...) list()
    } else {
      f <- purrr::possibly(gh::gh, otherwise = list())
    }
    f(
      "GET /repos/{owner}/{repo}",
      owner = repo_owner, repo = repo_name, .api_url = api_url
    )
  }
  repo_info <- purrr::pmap(
    grl[c("repo_owner", "repo_name", "api_url")],
    get_gh_repo
  )
  # NOTE: these can be two separate matters:
  # 1. Did we call the GitHub API? Means we know `is_fork` and the parent repo.
  # 2. If so, did we call it with auth? Means we know if we can push.
  grl$github_got <- map_lgl(repo_info, ~ length(.x) > 0)
  if (isTRUE(github_get) && any(!grl$github_got)) {
    oops <- which(!grl$github_got)
    oops_remotes <- grl$remote[oops]
    oops_hosts <- unique(grl$host[oops])
    ui_stop("
      Unable to get GitHub info for these remotes: {ui_value(oops_remotes)}
      Are we offline? Is GitHub down?
      Otherwise, you probably need to configure a personal access token (PAT) \\
      for {ui_value(oops_hosts)}
      See {ui_code('?gh_token_help')} for advice")
  }

  grl$is_fork <- map_lgl(repo_info, "fork", .default = NA)
  # `permissions` is an example of data that is not present if the request
  # did not include a PAT
  grl$can_push <- map_lgl(repo_info, c("permissions", "push"), .default = NA)
  grl$perm_known <- !is.na(grl$can_push)
  grl$parent_repo_owner <-
    map_chr(repo_info, c("parent", "owner", "login"), .default = NA)
  grl$parent_repo_name <-
    map_chr(repo_info, c("parent", "name"), .default = NA)
  grl$parent_repo_spec <-  make_spec(grl$parent_repo_owner, grl$parent_repo_name)

  parent_info <- purrr::pmap(
    set_names(
      grl[c("parent_repo_owner", "parent_repo_name", "api_url")],
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
#' Most usethis functions should call the higher-level functions `target_repo()`
#' or `target_repo_spec()`.
#'
#' Only functions that really need full access to the GitHub remote config
#' should call this directly. Ways to work with a config:
#' * `cfg <- github_remote_config(github_get = )`
#' * `check_for_bad_config(cfg)` errors for obviously bad configs (by default)
#'   or you can specify the configs considered to be bad
#' * Emit a custom message then call `stop_bad_github_remote_config()` directly
#' * If the config is suboptimal-but-supported, use
#'   `ui_github_remote_config_wat()` to educate the user and give them a chance
#'   to back out.
#'
#' Fields in an instance of `github_remote_config`:
#' * `type`: explained below
#' * `pr_ready`: Logical. Do the `pr_*()` functions support it?
#' * `desc`: A description used in messages and menus.
#' * `origin`: Information about the `origin` GitHub remote.
#' * `upstream`: Information about the `upstream` GitHub remote.
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
#'  Remote configuration "guesses" we apply when `github_get = FALSE` or when
#'  we make unauthorized requests (no PAT found) and therefore have no info on
#'  permissions
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
      host_url = NA_character_,
      pr_ready = FALSE,
      desc = "Unexpected remote configuration.",
      origin   = c(name = "origin",   is_configured = FALSE, ptype),
      upstream = c(name = "upstream", is_configured = FALSE, ptype)
    ),
    class = "github_remote_config"
  )
}

github_remote_config <- function(github_get = NA) {
  cfg <- new_github_remote_config()
  grl <- github_remotes(github_get = github_get)

  if (nrow(grl) == 0) {
    return(cfg_no_github(cfg))
  }

  cfg$origin$is_configured   <- "origin"   %in% grl$remote
  cfg$upstream$is_configured <- "upstream" %in% grl$remote

  single_remote <- xor(cfg$origin$is_configured, cfg$upstream$is_configured)

  if (!single_remote) {
    if (length(unique(grl$host)) != 1) {
      ui_stop("
        Internal error: Multiple GitHub hosts
        {ui_value(grl$host)}")
    }
    if (length(unique(grl$github_got)) != 1) {
      ui_stop("
        Internal error: Got GitHub API info for some remotes, but not all")
    }
    if (length(unique(grl$perm_known)) != 1) {
      ui_stop("
        Internal error: Know GitHub permissions for some remotes, but not all")
    }
  }
  cfg$host_url <- unique(grl$host_url)
  github_got <- any(grl$github_got)
  perm_known <- any(grl$perm_known)

  if (cfg$origin$is_configured) {
    cfg$origin <-
      utils::modifyList(cfg$origin, grl[grl$remote == "origin",])
  }

  if (cfg$upstream$is_configured) {
    cfg$upstream <-
      utils::modifyList(cfg$upstream, grl[grl$remote == "upstream",])
  }

  if (github_got && !single_remote) {
    cfg$origin$parent_is_upstream <-
      identical(cfg$origin$parent_repo_spec, cfg$upstream$repo_spec)
  }

  if (!github_got || !perm_known) {
    if (single_remote) {
      return(cfg_maybe_ours_or_theirs(cfg))
    } else {
      return(cfg_maybe_fork(cfg))
    }
  }
  # `github_got` must be TRUE
  # `perm_known` must be TRUE

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

#' Returns information about ONE GitHub repository. Used when we need to
#' designate which repo we will, e.g., open an issue on or activate a CI service
#' for. This information might be used in a GitHub API request or to form URLs.
#'

#' Examples:
#' * Badge URLs
#' * URLs where you can activate a CI service
#' * URLs for DESCRIPTION fields such as URL and BugReports

#' `target_repo()` passes `github_get` along to `github_remote_config()`. If
#' `github_get = TRUE`, `target_repo()` will error for configs other than
#' `"ours"` or `"fork"`. `target_repo()` always errors for bad configs. If
#' `github_get = NA` or `FALSE`, the "maybe" configs are tolerated.
#'
#' `target_repo_spec()` is a less capable function for when you just need an
#' `OWNER/REPO` spec. Currently, it does not set or offer control over
#' `github_get`, although I've considered explicitly setting `github_get =
#' FALSE` or adding this argument, defaulting to `FALSE`.
#'

#' @inheritParams github_remotes

#' @param cfg An optional GitHub remote configuration. Used to get the target
#'   repo when the function had some need for the full config.
#' @param role We use "source" to mean the principal repo where a project's
#'   development happens. We use "primary" to mean the principal repo this
#'   particular user interacts with or has the greatest power over. They can be
#'   the same or different. Examples:
#' * For a personal project you own, "source" and "primary" are the same.
#'   Presumably the `origin` remote.
#' * For a collaboratively developed project, an outside contributor must create
#'   a fork in order to make a PR. For such a person, their fork is "primary"
#'   (presumably `origin`) and the original repo that they forked is "source"
#'   (presumably `upstream`).
#' This is *almost* consistent with terminology used by the GitHub API. A fork
#' has a "source repo" and a "parent repo", which are usually the same. They
#' only differ when working with a fork of a repo that is itself a fork. In this
#' rare case, the parent is the immediate fork parent and the source is the
#' ur-parent, i.e. the root of this particular tree. The source repo is not a
#' fork.
#' @param ask In some configurations, if `ask = TRUE` and we're in an
#'   interactive session, user gets a choice between `origin` and `upstream`.
#' @keywords internal
#' @noRd
target_repo <- function(cfg = NULL,
                        github_get = NA,
                        role = c("source", "primary"),
                        ask = is_interactive()) {
  cfg <- cfg %||% github_remote_config(github_get = github_get)
  stopifnot(inherits(cfg, "github_remote_config"))
  role <- match.arg(role)

  check_for_bad_config(cfg)

  if (isTRUE(github_get)) {
    check_ours_or_fork(cfg)
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
    type = glue("Type = {ui_value(cfg$type)}"),
    host_url = glue("Host = {ui_value(cfg$host_url)}"),
    pr_ready = glue("Config supports a pull request = {ui_value(cfg$pr_ready)}"),
    origin = format_remote(cfg$origin),
    upstream = format_remote(cfg$upstream),
    desc = if (is.na(cfg$desc)) {
      glue("Desc = {ui_unset('no description')}")
    } else {
      glue("Desc = {cfg$desc}")
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

stop_maybe_github_remote_config <- function(cfg) {
  msg <- github_remote_config_wat(cfg)
  msg$type <- glue("
    Pull request functions can't work with GitHub remote configuration: \\
    {ui_value(cfg$type)}
    The most likely problem is that we aren't discovering your GitHub \\
    personal access token
    Call {ui_code('gh_token_help()')} for help")
  abort(
    message = unname(msg),
    class = c("usethis_error_invalid_pr_config", "usethis_error"),
    cfg = cfg
  )
}

check_for_bad_config <- function(cfg,
                                 bad_configs = c(
                                   "no_github",
                                   "fork_upstream_is_not_origin_parent",
                                   "fork_cannot_push_origin",
                                   "upstream_but_origin_is_not_fork"
                                 )) {
  if (cfg$type %in% bad_configs) {
    stop_bad_github_remote_config(cfg)
  }
  invisible()
}

check_for_maybe_config <- function(cfg,
                                   maybe_configs = c(
                                     "maybe_ours_or_theirs",
                                     "maybe_fork"
                                   )) {
  if (cfg$type %in% maybe_configs) {
    stop_maybe_github_remote_config(cfg)
  }
  invisible()
}

check_ours_or_fork <- function(cfg = NULL) {
  cfg <- cfg %||% github_remote_config(github_get = TRUE)
  stopifnot(inherits(cfg, "github_remote_config"))
  if (cfg$type %in% c("ours", "fork")) {
    return(invisible(cfg))
  }
  check_for_bad_config(cfg)
  check_for_maybe_config(cfg)
  ui_stop("
    Internal error: Unexpected GitHub remote configuration: {ui_value(cfg$type)}")
}

# github remote configurations -------------------------------------------------
# use for configs
read_more <- glue("
  Read more about the GitHub remote configurations that usethis supports at:
  {ui_value('https://happygitwithr.com/common-remote-setups.html')}")

read_more_maybe <- glue("
  Read more about what this GitHub remote configurations means at:
  {ui_value('https://happygitwithr.com/common-remote-setups.html')}")

cfg_no_github <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "no_github",
      pr_ready = FALSE,
      desc = glue("
        Neither {ui_value('origin')} nor {ui_value('upstream')} is a GitHub \\
        repo.

        {read_more}")
    )
  )
}

cfg_ours <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "ours",
      pr_ready = TRUE,
      desc = glue("
        {ui_value('origin')} is both the source and primary repo.

        {read_more}")
    )
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
        {ui_code('usethis::create_from_github()')} can do this.

        {read_more}")
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
        is either not configured or is not a GitHub repo.

        We may be offline or you may need to configure a GitHub personal access
        token. {ui_code('gh_token_help()')} can help with that.

        {read_more_maybe}")
    )
  )
}

cfg_fork <- function(cfg) {
  utils::modifyList(
    cfg,
    list(
      type = "fork",
      pr_ready = TRUE,
      desc = glue("
        {ui_value('origin')} is a fork of {ui_value(cfg$upstream$repo_spec)}, \\
        which is configured as the {ui_value('upstream')} remote.

        {read_more}")
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
        GitHub repos. However, we can't confirm their relationship to each \\
        other (e.g., fork and fork parent) or your permissions (e.g. push \\
        access).

        We may be offline or you may need to configure a GitHub personal access
        token. {ui_code('gh_token_help()')} can help with that.

        {read_more_maybe}")
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
        The {ui_value('origin')} remote is a fork, but you can't push to it.

        {read_more}")
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
        not configured as the {ui_value('upstream')} remote.

        {read_more}")
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
        is not a fork of {ui_value('upstream')}.

        {read_more}")
    )
  )
}
