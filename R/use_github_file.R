#' Copy a file from any GitHub repo into the current project
#'
#' Gets the content of a file from GitHub, from any repo the user can read, and
#' writes it into the active project. This function wraps an endpoint of the
#' GitHub API which supports specifying a target reference (i.e. branch, tag,
#' or commit) and which follows symlinks.
#'

#' @param repo_spec A string identifying the GitHub repo or, alternatively, a
#'   GitHub file URL. Acceptable forms:
#'   * Plain `OWNER/REPO` spec
#'   * A blob URL, such as `"https://github.com/OWNER/REPO/blob/REF/path/to/some/file"`
#'   * A raw URL, such as `"https://raw.githubusercontent.com/OWNER/REPO/REF/path/to/some/file"`
#'
#' In the case of a URL, the `path`, `ref`, and `host` are extracted from it, in
#' addition to the `repo_spec`. The URL form is not supported for GitHub
#' Enterprise; for GHE, use the individual arguments.
#' @param path Path of file to copy, relative to the GitHub repo it lives in.
#' @param save_as Path of file to create, relative to root of active project.
#'   Defaults to the last part of `path`, in the sense of `basename(path)` or
#'   `fs::path_file(path)`.
#' @param ref The name of a branch, tag, or commit. By default, the file at
#'   `path` will by copied from its current state in the repo's default branch.
#' @inheritParams use_template
#' @inheritParams use_github
#'
#' @return A logical indicator of whether a file was written, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' use_github_file(
#'   "https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml"
#' )
#'
#' use_github_file(
#'   "r-lib/actions",
#'   path = "examples/check-standard.yaml",
#'   save_as = ".github/workflows/R-CMD-check.yaml"
#' )
#' }
use_github_file <- function(repo_spec,
                            path = NULL,
                            save_as = NULL,
                            ref = NULL,
                            ignore = FALSE,
                            open = FALSE,
                            host = NULL) {

  check_string(repo_spec)
  dat <- parse_file_url(repo_spec)
  if (dat$parsed) {
    repo_spec <- dat$repo_spec
    path      <- dat$path
    ref       <- dat$ref
    host      <- dat$host
  }
  check_string(path)
  save_as <- save_as %||% path_file(path)
  check_string(save_as)
  maybe_string(ref)
  maybe_string(host)

  ref_string <- if (is.null(ref)) "" else glue("@{ref}")
  github_string <- glue("{repo_spec}/{path}{ref_string}")
  ui_done("Saving {ui_path(github_string)} to {ui_path(save_as)}")

  # https://docs.github.com/en/rest/reference/repos#contents
  # https://docs.github.com/en/rest/reference/repos#if-the-content-is-a-symlink
  # If the requested {path} points to a symlink, and the symlink's target is a
  # normal file in the repository, then the API responds with the content of the
  # file....
  tf <- withr::local_tempfile(
    pattern = glue("use_github_file-{path_file(save_as)}-")
  )
  res <- gh::gh(
    "/repos/{repo_spec}/contents/{path}",
    repo_spec = repo_spec, path = path,
    ref = ref,
    .destfile = tf,
    .accept = "application/vnd.github.v3.raw"
  )

  tf_contents <- read_utf8(tf)
  new <- write_over(proj_path(save_as), tf_contents)

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open && new) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}

# https://github.com/OWNER/REPO/blob/REF/path/to/some/file
# https://raw.githubusercontent.com/OWNER/REPO/REF/path/to/some/file
parse_file_url <- function(x) {
  out <- list(
    parsed = FALSE,
    repo_spec = x,
    path = NULL,
    ref = NULL,
    host = NULL
  )

  dat <- re_match(x, github_remote_regex)
  if (is.na(dat$.match)) {
    return(out)
  }

  if (!dat$host %in% c("raw.githubusercontent.com", "github.com") ||
      !nzchar(dat$fragment) ||
      (dat$host == "github.com" && !grepl("^/blob/", dat$fragment))) {
    ui_stop("Can't parse the URL provided via {ui_code('repo_spec')}.")
  }
  out$parsed <- TRUE

  dat$fragment <- sub("^/(blob/)?", "", dat$fragment)
  dat_fragment <- re_match(dat$fragment, "^(?<ref>[^/]+)/(?<path>.+)$")

  out$repo_spec <- make_spec(owner = dat$repo_owner, repo = dat$repo_name)
  out$path <- dat_fragment$path
  out$ref <- dat_fragment$ref
  out$host <- "https://github.com"

  out
}
