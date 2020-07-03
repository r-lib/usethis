github_remotes <- function() {
  remotes <- git_remotes()
  if (length(remotes) == 0) {
    return(NULL)
  }
  m <- vapply(remotes, function(x) grepl("github", x), logical(1))
  if (sum(m) == 0) {
    return(NULL)
  }
  remotes[m]
}

github_remote <- function(name) {
  remotes <- github_remotes()
  if (length(remotes) == 0) {
    return(NULL)
  }
  remotes[[name]]
}

github_remote_protocol <- function(name = "origin") {
  # https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
  url <- github_remote(name)
  if (is.null(url)) {
    return(NULL)
  }
  switch(
    substr(url, 1, 5),
    `https` = "https",
    `git@g` = "ssh",
    ui_stop(
      "Can't classify URL for {ui_value(name)} remote as \\
       {ui_value('ssh')}' or {ui_value('https')}:\\
       \n{ui_code(url)}"
    )
  )
}

## repo_spec --> owner, repo
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    ui_stop("{ui_code('repo_spec')} must be of form {ui_value('owner/repo')}.")
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo

## named vector or list of Git remote URLs --> named list of (owner, repo)
parse_github_remotes <- function(x) {
  # https://github.com/r-lib/devtools.git --> rlib, devtools
  # https://github.com/r-lib/devtools     --> rlib, devtools
  # git@github.com:r-lib/devtools.git     --> rlib, devtools
  # git@github.com:/r-hub/rhub.git        --> r-hub, rhub
  re <- "github[^/:]*[:/]{1,2}([^/]+)/(.*?)(?:\\.git)?$"
  ## on R < 3.4.2, regexec() fails to apply as.character() to first 2 args,
  ## though it is documented
  m <- regexec(re, as.character(x))
  match <- stats::setNames(regmatches(as.character(x), m), names(x))
  lapply(match, function(y) list(owner = y[[2]], repo = y[[3]]))
}

github_url_rx <- function() {
  paste0(
    "^",
    "(?:https?://github.com/)",
    "(?<owner>[^/]+)/",
    "(?<repo>[^/#]+)",
    "/?",
    "(?<fragment>.*)",
    "$"
  )
}

github_remote_from_description <- function(desc) {
  stopifnot(inherits(desc, "description"))
  urls <- c(
    desc$get_field("BugReports", default = character()),
    desc$get_urls()
  )
  gh_links <- grep("^https?://github.com/", urls, value = TRUE)
  if (length(gh_links) > 0) {
    remote <- rematch2::re_match(gh_links[[1]], github_url_rx())
    as.list(remote[c("owner", "repo")])
  }
}
