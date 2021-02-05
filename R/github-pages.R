#' Configure a GitHub Pages site
#'
#' Activates or reconfigures a GitHub Pages site for a project hosted on GitHub.
#' This function anticipates two specific usage modes:
#' * Publish from the root directory of a `gh-pages` branch, which is assumed to
#'   be only (or at least primarily) a remote branch. Typically the `gh-pages`
#'   branch is managed by an automatic "build and deploy" job, such as the one
#'   configured by [`use_github_action("pkgdown")`][use_github_action()].
#' * Publish from the `"/docs"` directory of a "regular" branch, probably the
#'   repo's default branch. The user is assumed to have a plan for how they will
#'   manage the content below `"/docs"`.
#'

#' @param branch,path Branch and path for the site source. The default of
#'   `branch = "gh-pages"` and `path = "/"` reflects strong GitHub support for
#'   this configuration: when a `gh-pages` branch is first created, it is
#'   *automatically* published to Pages, using the source found in `"/"`. If a
#'   `gh-pages` branch does not yet exist on the host, `use_github_pages()`
#'   creates an empty, orphan remote branch.
#'
#'   The most common alternative is to use the repo's default branch, coupled
#'   with `path = "/docs"`. It is the user's responsibility to ensure that this
#'   `branch` pre-exists on the host.
#'
#'   Note that GitHub does not support an arbitrary `path` and, at the time of
#'   writing, only `"/"` or `"/docs"` are accepted.

#' @param cname Optional, custom domain name. The `NA` default means "don't set
#'   or change this", whereas a value of `NULL` removes any previously
#'   configured custom domain.
#'
#'   Note that this *can* add or modify a CNAME file in your repository. If you
#'   are using Pages to host a pkgdown site, it is better to specify its URL in
#'   the pkgdown config file and let pkgdown manage CNAME.
#'

#' @seealso
#' * [use_pkgdown_github_pages()] combines `use_github_pages()` with other functions to
#' fully configure a pkgdown site
#' * <https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages>
#' * <https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#pages>

#' @return Site metadata returned by the GitHub API, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' use_github_pages()
#' use_github_pages(branch = git_branch_default(), path = "/docs")
#' }
use_github_pages <- function(branch = "gh-pages", path = "/", cname = NA) {
  stopifnot(is_string(branch), is_string(path))
  stopifnot(is.na(cname) || is.null(cname) || is_string(cname))
  tr <- target_repo(github_get = TRUE)
  if (!isTRUE(tr$can_push)) {
    ui_stop("
      You don't seem to have push access for {ui_value(tr$repo_spec)}, which \\
      is required to turn on GitHub Pages.")
  }
  gh <- gh_tr(tr)
  safe_gh <- purrr::safely(gh)

  if (branch == "gh-pages") {
    new_branch <- create_gh_pages_branch(tr, branch = "gh-pages")
    if (new_branch) {
      # merely creating gh-pages branch automatically activates publishing
      # BUT we need to give the servers time to sync up before a new GET
      # retrieves accurate info... ask me how I know
      Sys.sleep(2)
    }
  }

  site <- safe_gh("GET /repos/{owner}/{repo}/pages")[["result"]]

  if (is.null(site)) {
    ui_done("Activating GitHub Pages for {ui_value(tr$repo_spec)}")
    site <- gh(
      "POST /repos/{owner}/{repo}/pages",
      source = list(branch = branch, path = path),
      .accept = "application/vnd.github.switcheroo-preview+json"
    )
  }

  need_update <-
    site$source$branch != branch ||
    site$source$path != path ||
    (is.null(cname) && !is.null(site$cname)) ||
    (is_string(cname) && (is.null(site$cname) || cname != site$cname))

  if (need_update) {
    args <- list(
      endpoint = "PUT /repos/{owner}/{repo}/pages",
      source = list(branch = branch, path = path)
    )
    if (is.null(cname) && !is.null(site$cname)) {
      # this goes out as a JSON `null`, which is necessary to clear cname
      args$cname <- NA
    }
    if (is_string(cname) && (is.null(site$cname) || cname != site$cname)) {
      args$cname <- cname
    }
    Sys.sleep(2)
    exec(gh, !!!args)
    Sys.sleep(2)
    site <- safe_gh("GET /repos/{owner}/{repo}/pages")[["result"]]
  }

  ui_done("GitHub Pages is publishing from:")
  if (!is.null(site$cname)) {
    kv_line("Custom domain", site$cname)
  }
  kv_line("URL", site$html_url)
  kv_line("Branch", site$source$branch)
  kv_line("Path", site$source$path)

  invisible(site)
}

# returns FALSE if it does NOT create the branch (because it already exists)
# returns TRUE if it does create the branch
create_gh_pages_branch <- function(tr, branch = "gh-pages") {
  gh <- gh_tr(tr)
  safe_gh <- purrr::safely(gh)

  branch_GET <- safe_gh(
    "GET /repos/{owner}/{repo}/branches/{branch}",
    branch = branch
  )

  if (!inherits(branch_GET$error, "http_error_404")) {
    return(FALSE)
  }

  ui_done("
    Initializing empty, orphan {ui_value(branch)} branch in GitHub repo \\
    {ui_value(tr$repo_spec)}")

  # git hash-object -t tree /dev/null
  sha_empty_tree <- "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

  # Create commit with empty tree
  res <- gh(
    "POST /repos/{owner}/{repo}/git/commits",
    message = "first commit",
    tree = sha_empty_tree
  )

  # Assign ref to above commit
  gh(
    "POST /repos/{owner}/{repo}/git/refs",
    ref = "refs/heads/gh-pages",
    sha = res$sha
  )

  TRUE
}
