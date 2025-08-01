# Functions that are in a grey area between usethis and gh

gh_tr <- function(tr) {
  force(tr)
  function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      owner = tr$repo_owner,
      repo = tr$repo_name,
      .api_url = tr$api_url
    )
  }
}

# Functions inlined from gh ----
get_baseurl <- function(url) {
  # https://github.uni.edu/api/v3/
  if (!any(grepl("^https?://", url))) {
    stop("Only works with HTTP(S) protocols")
  }
  prot <- sub("^(https?://).*$", "\\1", url) # https://
  rest <- sub("^https?://(.*)$", "\\1", url) #         github.uni.edu/api/v3/
  host <- sub("/.*$", "", rest) #         github.uni.edu
  paste0(prot, host) # https://github.uni.edu
}

# https://api.github.com --> https://github.com
# api.github.com --> github.com
normalize_host <- function(x) {
  sub("api[.]github[.]com", "github.com", x)
}

get_hosturl <- function(url) {
  url <- get_baseurl(url)
  normalize_host(url)
}

# (almost) the inverse of get_hosturl()
# https://github.com     --> https://api.github.com
# https://github.uni.edu --> https://github.uni.edu/api/v3
# fmt: skip
get_apiurl <- function(url) {
  host_url <- get_hosturl(url)
  prot_host <- strsplit(host_url, "://", fixed = TRUE)[[1]]
  if (is_github_dot_com(host_url)) {
    paste0(prot_host[[1]], "://api.github.com")
  } else if (is_github_enterprise(host_url)) {
    paste0(prot_host[[1]], "://api.", prot_host[[2]])
  } else {
    paste0(host_url, "/api/v3")
  }
}

is_github_dot_com <- function(url) {
  url <- get_baseurl(url)
  url <- normalize_host(url)
  grepl("^https?://github.com", url)
}

default_api_url <- function() {
  Sys.getenv("GITHUB_API_URL", unset = "https://api.github.com")
}

# handles GitHub Enterprise Cloud, but not GitHub Enterprise Server (which
# would, I think, require the ability to fully configure this)
# https://github.com/r-lib/usethis/issues/1897
is_github_enterprise <- function(url) {
  url <- get_baseurl(url)
  url <- normalize_host(url)
  grepl("^https?://.+ghe.com", url)
}
