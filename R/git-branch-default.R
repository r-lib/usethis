#' Determine default Git branch
#'
#' Figure out the default branch of the current Git repo.
#'
#' @return A branch name
#' @export
#'
#' @examples
#' \dontrun{
#' git_branch_default()
#' }
git_branch_default <- function() {
  check_uses_git()
  repo <- git_repo()

  gb <- gert::git_branch_list(local = TRUE, repo = repo)[["name"]]
  if (length(gb) == 1) {
    return(gb)
  }

  # Check the most common names used for the default branch
  gb <- set_names(gb)
  usual_suspects_branchname <- c("main", "master", "default")
  branch_candidates <- purrr::discard(gb[usual_suspects_branchname], is.na)

  if (length(branch_candidates) == 1) {
    return(branch_candidates[[1]])
  }
  # either 0 or >=2 of the usual suspects are present

  # Can we learn what HEAD points to on a relevant Git remote?
  gr <- git_remotes()
  usual_suspects_remote <- c("upstream", "origin")
  gr <- purrr::compact(gr[usual_suspects_remote])

  if (length(gr)) {
    remote_names <- set_names(names(gr))

    # check symbolic ref, e.g. refs/remotes/origin/HEAD (a local operation)
    remote_heads <- map(
      remote_names,
      ~ gert::git_remote_info(.x, repo = repo)$head
    )
    remote_heads <- purrr::compact(remote_heads)
    if (length(remote_heads)) {
      return(path_file(remote_heads[[1]]))
    }

    # ask the remote (a remote operation)
    f <- function(x) {
      dat <- gert::git_remote_ls(remote = x, verbose = FALSE, repo = repo)
      path_file(dat$symref[dat$ref == "HEAD"])
    }
    f <- purrr::possibly(f, otherwise = NULL)
    remote_heads <- purrr::compact(map(remote_names, f))
    if (length(remote_heads)) {
      return(remote_heads[[1]])
    }
  }
  # no luck consulting usual suspects re: Git remotes
  # go back to locally configured branches

  # Is init.defaultBranch configured?
  # https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch
  init_default_branch <- git_cfg_get("init.defaultBranch")
  if ((!is.null(init_default_branch)) && (init_default_branch %in% gb)) {
    return(init_default_branch)
  }

  # take first existing branch from usual suspects
  if (length(branch_candidates)) {
    return(branch_candidates[[1]])
  }

  # take first existing branch
  if (length(gb)) {
    return(gb[[1]])
  }

  # I think this means we are on an unborn branch
  ui_stop("
    Can't determine the default branch for this repo
    Do you need to make your first commit?")
}
