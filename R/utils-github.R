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

## named vector or list of GitHub URLs --> data frame of URL parts
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
