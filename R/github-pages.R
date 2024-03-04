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
#' * [use_pkgdown_github_pages()] combines `use_github_pages()` with other
#' functions to fully configure a pkgdown site
#' * <https://docs.github.com/en/pages>
#' * <https://docs.github.com/en/rest/pages>

#' @return Site metadata returned by the GitHub API, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' use_github_pages()
#' use_github_pages(branch = git_default_branch(), path = "/docs")
#' }
use_github_pages <- function(branch = "gh-pages", path = "/", cname = NA) {
  check_name(branch)
  check_name(path)
  check_string(cname, allow_empty = FALSE, allow_na = TRUE, allow_null = TRUE)
  tr <- target_repo(github_get = TRUE, ok_configs = c("ours", "fork"))
  check_can_push(tr = tr, "to turn on GitHub Pages")

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
    ui_bullets(c(
      "v" = "Activating GitHub Pages for {.val {tr$repo_spec}}."
    ))
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

  ui_bullets(c("v" = "GitHub Pages is publishing from:"))
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

  ui_bullets(c(
    "v" = "Initializing empty, orphan branch {.val {branch}} in GitHub repo
           {.val {tr$repo_spec}}."
  ))

  # GitHub no longer allows you to directly create an empty tree
  # hence this roundabout method of getting an orphan branch with no files
  tree <- gh(
    "POST /repos/{owner}/{repo}/git/trees",
    tree = list(list(
      path = "_temp_file_ok_to_delete",
      mode = "100644",
      type = "blob",
      content = ""
    ))
  )
  commit <- gh(
    "POST /repos/{owner}/{repo}/git/commits",
    message = "Init orphan branch",
    tree = tree$sha
  )
  ref <- gh(
    "POST /repos/{owner}/{repo}/git/refs",
    ref = glue("refs/heads/{branch}"),
    sha = commit$sha
  )
  # this should succeed, but if somehow it does not, it's not worth failing and
  # leaving pkgdown + GitHub Pages setup half-done --> why I use safe_gh()
  safe_gh(
    "DELETE /repos/{owner}/{repo}/contents/_temp_file_ok_to_delete",
    message = "Remove temp file",
    sha = purrr::pluck(tree, "tree", 1, "sha"),
    branch = branch
  )

  TRUE
}
