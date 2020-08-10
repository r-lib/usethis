github_remote_protocol <- function(name = "origin") {
  # https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
  url <- github_remotes("origin", github_get = FALSE)$url
  if (length(url) == 0) {
    return()
  }
  protocol <- parse_github_remotes(url)$protocol
  if (is.na(protocol)) {
    ui_stop("
      Can't classify the URL for {ui_value(name)} remote as \\
      \"https\" or \"ssh\":
      {ui_value(url)}")
  }
  protocol
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
  ifelse(no_spec, NA_character_, glue("{owner}/{repo}"))
}

# named vector or list of GitHub URLs --> data frame of URL parts
parse_github_remotes <- function(x) {
  # https://github.com/r-lib/usethis             --> https, rlib, usethis
  # https://github.com/r-lib/usethis.git         --> https, rlib, usethis
  # https://github.com/r-lib/usethis#readme      --> https, rlib, usethis
  # https://github.com/r-lib/usethis/issues/1169 --> https, rlib, usethis
  # git@github.com:r-lib/usethis.git             --> ssh,   rlib, usethis
  re <- paste0(
    "^",
    "(?<prefix>[htpsgit]+)",
    "[:/@]+",
    "github.com[:/]",
    "(?<repo_owner>[^/]+)",
    "/",
    "(?<repo_name>[^/#]+)",
    "(?<fragment>.*)",
    "$"
  )
  dat <- rematch2::re_match(x, re)
  dat$protocol <- ifelse(dat$prefix == "https", "https", "ssh")
  dat$name <- if (rlang::is_named(x)) names(x) else NA_character_
  dat$repo_name <- sub("[.]git$", "", dat$repo_name)
  dat[c("name", "repo_owner", "repo_name", "protocol")]
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
#'   to add this info if: (1) we are online and (2) we have a PAT. An explicit
#'   `TRUE` or `FALSE` is taken literally. Technically, for public repos, we can
#'   get most of this data from the API without a PAT, but until I have reason
#'   to plan for that scenario, I choose not to bother.
#' @inheritParams use_github
#' @keywords internal
#' @noRd
github_remotes <- function(these = c("origin", "upstream"),
                           github_get = NA,
                           auth_token = github_token(),
                           host = "https://api.github.com") {
  if (is.na(github_get)) {
    github_get <- is_online("github.com") && have_github_token(auth_token)
  }
  if (isTRUE(github_get)) {
    check_github_token(auth_token)
  }
  grl <- data.frame(
    remote = NA_character_,
    url = NA_character_,
    repo_owner = NA_character_,
    repo_name = NA_character_,
    repo_spec = NA_character_,
    github_get = NA,
    is_fork = NA,
    can_push = NA,
    parent_repo_owner = NA_character_,
    parent_repo_name = NA_character_,
    parent_repo_spec = NA_character_,
    can_push_to_parent = NA,
    stringsAsFactors = FALSE
  )

  x <- gert::git_remote_list(repo = git_repo())
  is_github <- grepl("github", x$url)
  is_one_of_these <- if (length(these) > 0) x$name %in% these else TRUE
  x <- x[is_github & is_one_of_these, ]
  if (nrow(x) == 0) {
    return(grl[0, ])
  }
  grl <- grl[rep_len(1, nrow(x)), ]
  grl$github_get <- github_get

  grl$remote <- x$name
  grl$url <- x$url

  parsed <- parse_github_remotes(grl$url)
  grl$repo_owner <- parsed$repo_owner
  grl$repo_name <- parsed$repo_name
  grl$repo_spec <-  make_spec(grl$repo_owner, grl$repo_name)

  if (!github_get) {
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
  # `permissions` is an example of data that is not present if the request
  # did not include a PAT
  grl$can_push <- map_lgl(repo_info, c("permissions", "push"), .default = NA)
  grl$parent_repo_owner <-
    map_chr(repo_info, c("parent", "owner", "login"), .default = NA)
  grl$parent_repo_name <-
    map_chr(repo_info, c("parent", "name"), .default = NA)
  grl$parent_repo_spec <-  make_spec(grl$parent_repo_owner, grl$parent_repo_name)

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
#' other downstream functions can decide whether to proceed / abort / complain &
#' offer to fix.
#' We only consider the remotes where:
#' * Name is `origin` or `upstream` and URL contains the string `"github"`
#'
#' We assume the project is a Git repo, so use this behind a guard like
#' `check_uses_git()`.
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
github_remote_config <- function(github_get = NA,
                                 auth_token = github_token(),
                                 host = "https://api.github.com") {
  cfg <- new_github_remote_config()
  grl <- github_remotes(
    github_get = github_get,
    auth_token = auth_token,
    host = host
  )

  if (nrow(grl) == 0) {
    return(cfg_no_github(cfg))
  }

  github_get <- grl$github_get[1] # assuming it's same for origin and upstream
  cfg$origin$is_configured   <- "origin"   %in% grl$remote
  cfg$upstream$is_configured <- "upstream" %in% grl$remote

  if (cfg$origin$is_configured) {
    cols <- intersect(names(grl), names(cfg$origin))
    origin <- grl[grl$remote == "origin", cols]
    cfg$origin <- utils::modifyList(cfg$origin, origin)
  }

  if (cfg$upstream$is_configured) {
    cols <- intersect(names(grl), names(cfg$upstream))
    upstream <- grl[grl$remote == "upstream", cols]
    cfg$upstream <- utils::modifyList(cfg$upstream, upstream)
  }
  # cfg is as complete as it can be if `github_get` is `FALSE`

  single_remote <- xor(cfg$origin$is_configured, cfg$upstream$is_configured)

  if (!isTRUE(github_get)) {
    if (single_remote) {
      return(cfg_maybe_ours_or_theirs(cfg))
    } else {
      return(cfg_maybe_fork(cfg))
    }
  }
  # `github_get` must be `TRUE`

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

new_github_remote_config <- function() {
  structure(
    list(
      type = NA_character_,
      pr_ready = FALSE,
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
    class = "github_remote_config"
  )
}

#' Get a repo spec
#'
#' @description
#' Returns a repo spec of the form OWNER/REPO for, e.g., incorporating into a URL.
#' Examples:
#' * Badge URLs
#' * URLs where you can activate a CI service
#' * URLs for DESCRIPTION fields such as URL and BugReports
#'
#' If `cfg` is not provided, `repo_spec()` calls
#' `github_remote_config(github_get = FALSE)` and works only with locally
#' available information about GitHub remotes. To work with full GitHub remote
#' configuration, call `github_remote_config(github_get = TRUE)` yourself and
#' pass the resulting `cfg` in. `repo_spec()` will challenge certain configs,
#' e.g., "fork_upstream_is_not_origin_parent", and ask if user wants to back out
#' and fix the remote configuration.
#'
#' In some configurations, if `ask = TRUE` and we're in an interactive session,
#' user gets a choice between `origin` and (if either exists or is known) its
#' parent repo and `upstream`.
#'
#' @inheritParams use_github
#' @keywords internal
#' @noRd
repo_spec <- function(cfg = NULL,
                      role = c("source", "primary"),
                      ask = is_interactive(),
                      auth_token = github_token(),
                      host = "https://api.github.com") {
  cfg <- cfg %||%
    github_remote_config(github_get = FALSE, auth_token = auth_token, host = host)
  stopifnot(inherits(cfg, "github_remote_config"))
  role <- match.arg(role)

  if (cfg$type == "no_github") {
    stop_bad_github_remote_config(cfg)
  }

  weird_configs <- c(
    "fork_upstream_is_not_origin_parent",
    "fork_cannot_push_origin",
    "upstream_but_origin_is_not_fork"
  )
  if (is_interactive() && cfg$type %in% weird_configs) {
    if (ui_github_remote_config_wat(cfg)) {
      ui_stop("Exiting due to unfavorable GitHub config")
    }
  }

  # upstream only
  if (cfg$upstream$is_configured && !cfg$origin$is_configured) {
    return(cfg$upstream$repo_spec)
  }

  # origin only
  if (cfg$origin$is_configured && !cfg$upstream$is_configured) {
    if (is.na(cfg$origin$parent_repo_spec)) {
      return(cfg$origin$repo_spec)
    }
  }
  # scenarios left (X means "not NA", - means "is NA"):
  # origin origin_parent upstream
  #   X          X          -
  #   X          -          X
  #   X          X    ==    X
  #   X          X    !=    X

  if (!ask || !is_interactive()) {
    return(switch(
      role,
      source  = cfg$origin$parent_repo_spec %|% cfg$upstream$repo_spec,
      primary = cfg$origin$repo_spec
    ))
  }

  spec <- list(
    origin        = cfg$origin$repo_spec,
    origin_parent = cfg$origin$parent_repo_spec,
    upstream      = cfg$upstream$repo_spec
  )
  formatted <- c(
    origin        = glue("{spec$origin} = {ui_value('origin')}"),
    origin_parent = glue("{spec$origin_parent} = parent of {ui_value('origin')}"),
    upstream      = glue("{spec$upstream} = {ui_value('upstream')}")
  )

  spec <- spec[!is.na(spec)]
  if (length(spec) == 3 &&
      identical(spec[["origin_parent"]], spec[["upstream"]])) {
    spec <- spec[c("origin", "upstream")]
  }
  choices <- formatted[names(spec)]
  title <- glue("Which repo should we target?")
  choice <- utils::menu(choices, graphics = FALSE, title = title)
  spec[[choice]]
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
