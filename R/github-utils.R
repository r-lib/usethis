uses_github <- function(path = ".") {
  if (!uses_git(path))
    return(FALSE)

  r <- git2r::repository(path, discover = TRUE)
  r_remote_urls <- git2r::remote_url(r)

  any(grepl("github", r_remote_urls))
}

github_info <- function(path = ".", remote_name = NULL) {
  if (!uses_github(path))
    return(github_dummy)

  r <- git2r::repository(path, discover = TRUE)
  r_remote_urls <- grep("github", remote_urls(r), value = TRUE)

  if (!is.null(remote_name) && !remote_name %in% names(r_remote_urls))
    stop("no github-related remote named ", remote_name, " found")

  remote_name <- c(remote_name, "origin", names(r_remote_urls))
  x <- r_remote_urls[remote_name]
  x <- x[!is.na(x)][1]

  github_remote_parse(x)
}

github_dummy <- list(username = "<USERNAME>", repo = "<REPO>", fullname = "<USERNAME>/<REPO>")


remote_urls <- function(r) {
  remotes <- git2r::remotes(r)
  stats::setNames(git2r::remote_url(r, remotes), remotes)
}

github_remote_parse <- function(x) {
  if (length(x) == 0) return(github_dummy)
  if (!grepl("github", x)) return(github_dummy)

  if (grepl("^(https|git)", x)) {
    # https://github.com/hadley/devtools.git
    # https://github.com/hadley/devtools
    # git@github.com:hadley/devtools.git
    re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
  } else {
    stop("Unknown GitHub repo format", call. = FALSE)
  }

  m <- regexec(re, x)
  match <- regmatches(x, m)[[1]]
  list(
    username = match[2],
    repo = match[3],
    fullname = paste0(match[2], "/", match[3])
  )
}
