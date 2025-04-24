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
#' addition to the `repo_spec`.
#' @param path Path of file to copy, relative to the GitHub repo it lives in.
#'   This is extracted from `repo_spec` when user provides a URL.
#' @param save_as Path of file to create, relative to root of active project.
#'   Defaults to the last part of `path`, in the sense of `basename(path)` or
#'   `fs::path_file(path)`.
#' @param ref The name of a branch, tag, or commit. By default, the file at
#'   `path` will be copied from its current state in the repo's default branch.
#'   This is extracted from `repo_spec` when user provides a URL.
#' @inheritParams use_template
#' @inheritParams use_github
#' @inheritParams write_over
#'
#' @return A logical indicator of whether a file was written, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' use_github_file(
#'   "https://github.com/r-lib/actions/blob/v2/examples/check-standard.yaml"
#' )
#'
#' use_github_file(
#'   "r-lib/actions",
#'   path = "examples/check-standard.yaml",
#'   ref = "v2",
#'   save_as = ".github/workflows/R-CMD-check.yaml"
#' )
#' }
use_github_file <- function(
  repo_spec,
  path = NULL,
  save_as = NULL,
  ref = NULL,
  ignore = FALSE,
  open = FALSE,
  overwrite = FALSE,
  host = NULL
) {
  check_name(repo_spec)
  maybe_name(path)
  maybe_name(save_as)
  maybe_name(ref)
  check_bool(ignore)
  check_bool(open)
  check_bool(overwrite)
  maybe_name(host)

  dat <- parse_file_url(repo_spec)
  if (dat$parsed) {
    repo_spec <- dat$repo_spec
    path <- dat$path
    ref <- dat$ref
    host <- dat$host
  }

  save_as <- save_as %||% path_file(path)

  ref_string <- if (is.null(ref)) "" else glue("@{ref}")
  github_string <- glue("{repo_spec}/{path}{ref_string}")
  ui_bullets(c(
    "v" = "Saving {.val {github_string}} to {.path {pth(save_as)}}."
  ))

  lines <- read_github_file(
    repo_spec = repo_spec,
    path = path,
    ref = ref,
    host = host
  )
  new <- write_over(
    proj_path(save_as),
    lines,
    quiet = TRUE,
    overwrite = overwrite
  )

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open && new) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}

read_github_file <- function(repo_spec, path, ref = NULL, host = NULL) {
  # https://docs.github.com/en/rest/reference/repos#contents
  # https://docs.github.com/en/rest/reference/repos#if-the-content-is-a-symlink
  # If the requested {path} points to a symlink, and the symlink's target is a
  # normal file in the repository, then the API responds with the content of the
  # file....
  tf <- withr::local_tempfile()
  gh::gh(
    "/repos/{repo_spec}/contents/{path}",
    repo_spec = repo_spec,
    path = path,
    ref = ref,
    .api_url = host,
    .destfile = tf,
    .accept = "application/vnd.github.v3.raw"
  )
  read_utf8(tf)
}

# https://github.com/OWNER/REPO/blob/REF/path/to/some/file
# https://raw.githubusercontent.com/OWNER/REPO/REF/path/to/some/file
# https://github.acme.com/OWNER/REPO/blob/REF/path/to/some/file
# https://raw.github.acme.com/OWNER/REPO/REF/path/to/some/file
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

  # TODO: generalize here for GHE hosts that don't include 'github'
  if (!grepl("github", dat$host)) {
    ui_abort("URL doesn't seem to be associated with GitHub.")
  }

  if (
    !grepl("^(raw[.])?github", dat$host) ||
      !nzchar(dat$fragment) ||
      (grepl("^github", dat$host) && !grepl("^/blob/", dat$fragment))
  ) {
    ui_abort("Can't parse the URL provided via {.arg repo_spec}.")
  }
  out$parsed <- TRUE

  dat$host <- sub("^raw[.]", "", dat$host)
  dat$host <- sub("^githubusercontent", "github", dat$host)

  dat$fragment <- sub("^/(blob/)?", "", dat$fragment)
  dat_fragment <- re_match(dat$fragment, "^(?<ref>[^/]+)/(?<path>.+)$")

  out$repo_spec <- make_spec(owner = dat$repo_owner, repo = dat$repo_name)
  out$path <- dat_fragment$path
  out$ref <- dat_fragment$ref
  out$host <- glue_chr("https://{dat$host}")

  out
}
