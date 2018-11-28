#' Helpers for GitHub pull requests
#'
#' @description
#' * `pr_init("name")` creates a new local branch for a PR.
#' * `pr_create(number)` downloads a remote PR so you can edit locally.
#' * `pr_push()` pushes local changes to GitHub, after checking that there
#'    aren't any remote changes you need to retrieve first. On first use,
#'    it will prompt you to create a PR on GitHub.
#' * `pr_pull()` retrives changes from the GitHub PR. Run this if others
#'    have made suggestions or pushed into your PR.
#' * `pr_view()` open the PR in the browser
#'
#' @details
#' These functions have been designed to support the git and GitHub best
#' practices described in <http://happygitwithr.com/>.
#' @export
#' @param branch branch name. Should usually consist of lower case letters,
#'   numbers, and `-`.
pr_init <- function(branch) {
  check_uses_github()
  check_branch_current("master")

  if (!git_branch_exists(branch)) {
    if (git_branch_name() != "master") {
      if (nope("Create local PR branch with non-master parent?")) {
        return(invisible(FALSE))
      }
    }

    done("Creating local PR branch {value(branch)}")
    git_branch_create(branch)
  }

  if (git_branch_name() != branch) {
    done("Switching to branch {value(branch)}")
    git_branch_switch(branch)
  }

  todo("Use {code('pr_push()')} to create PR")
  invisible()
}

#' @export
#' @rdname pr_init
#' @param number Number of PR to fetch.
pr_fetch <- function(number) {
  done("Retrieving PR data")
  pr <- gh::gh("GET /repos/:owner/:repo/pulls/:number",
    owner = github_owner(),
    repo = github_repo(),
    number = number
  )

  user <- pr$user$login
  ref <- pr$head$ref
  branch <- paste0(user, "-", ref)
  remote <- paste0(user, "/", ref)

  if (!user %in% git2r::remotes(git_repo())) {
    done("Adding remote {remote}")
    git2r::remote_add(git_repo(), user, pr$head$repo$git_url)
  }

  if (!git_branch_exists(branch)) {
    done("Creating local branch {branch}")
    git2r::fetch(git_repo(), user, refspec = remote, verbose = FALSE)
    git_branch_create(branch, remote)
    git_branch_track(branch, user, ref)
  }

  if (git_branch_name() != branch) {
    done("Switching to branch {value(branch)}")
    git_branch_switch(branch)
  }
}

#' @export
#' @rdname pr_init
pr_push <- function() {
  check_uses_github()
  check_branch_not_master()
  check_uncommitted_changes()

  branch <- git_branch_name()
  if (is.null(git_branch_remote(branch))) {
    done("Tracking remote PR branch")
    git_branch_track(branch)
  }
  check_branch_current()

  done("Pushing changes to GitHub PR")
  git_branch_push(branch)

  # Prompt to create on first push
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    done("View PR at {value(url)}")
  }
}

#' @export
#' @rdname pr_init
pr_pull <- function() {
  check_uses_github()
  check_branch_not_master()
  check_uncommitted_changes()

  done("Pulling changes from GitHub PR")
  utils::capture.output(git2r::pull(git_repo()))

  invisible(TRUE)
}

#' @export
#' @rdname pr_init
pr_view <- function() {
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    view_url(pr_url())
  }
}

pr_create_gh <- function() {
  owner <- github_owner()
  repo <- github_repo()
  branch <- git_branch_name()

  done("Create PR at:")
  view_url(glue("https://github.com/{owner}/{repo}/compare/{branch}"))
}

pr_url <- function() {
  repo <- git_repo()
  branch <- git_branch_name()

  # Look first in cache (stored in git config)
  config_url <- glue("branch.{branch}.pull-url")
  url <- git2r::config()$local[[config_url]]
  if (!is.null(url)) {
    return(url)
  }

  # Look at all PRs
  prs <- gh::gh("GET /repos/:owner/:repo/pulls",
    owner = github_owner(),
    repo = github_repo(),
    .limit = Inf
  )
  refs <- vapply(prs, function(x) x$head$ref %||% NA_character_, character(1))
  match <- which(refs == branch)

  if (length(match) == 0) {
    NULL
  } else if (length(match) > 1) {
    stop("Multiple PRs correspond to this branch. Please close before continuing", call = FALSE)
  } else {
    url <- prs[[match]]$html_url

    config <- list(repo, url)
    names(config) <- c("repo", config_url)
    do.call(git2r::config, config)

    url
  }
}

# Checkers -----------------------------------------------------------------

check_branch_not_master <- function() {
  if (git_branch_name() != "master") {
    return()
  }

  stop_glue("
    Currently on master branch.
    Do you need to call {code('pr_init()')} first?
  ")
}

check_branch_current <- function(branch = git_branch_name()) {
  done("Checking that {branch} branch is up to date")
  diff <- git_branch_compare(branch)

  if (diff[[2]] == 0) {
    return()
  }

  stop_glue("
    {branch} branch is out of date.
    Please resolve (somehow) before continuing.
  ")
}

# Git helpers -------------------------------------------------------------

git_repo <- function() {
  check_uses_git()
  git2r::repository(proj_path())
}

git_commit_find <- function(refspec = NULL) {
  repo <- git_repo()

  if (is.null(refspec)) {
    git2r::last_commit(repo)
  } else {
    git2r::revparse_single(repo, refspec)
  }
}

git_branch_name <- function() {
  repo <- git_repo()

  branch <- git2r::repository_head(repo)
  if (!git2r::is_branch(branch)) {
    stop("Detached head; can't continue", call. = FALSE)
  }

  branch$name
}

git_branch_exists <- function(branch) {
  repo <- git_repo()
  branch %in% names(git2r::branches(repo))
}

git_branch_create <- function(branch, commit = NULL) {
  git2r::branch_create(git_commit_find(commit), branch)
}

git_branch_switch <- function(branch) {
  git2r::checkout(git_repo(), branch)
}

git_branch_compare <- function(branch = git_branch_name()) {
  repo <- git_repo()
  git2r::fetch(repo, "origin", refspec = branch, verbose = FALSE)
  git2r::ahead_behind(
    git_commit_find(branch),
    git_commit_find(paste0("origin/", branch))
  )
}

git_branch_push <- function(branch = git_branch_name(), force = FALSE) {
  branch_obj <- git2r::branches(git_repo())[[branch]]

  upstream <- git2r::branch_get_upstream(branch_obj)
  if (is.null(upstream)) {
    stop("Branch does not track a remote", call. = FALSE)
  }
  name <- git2r::branch_remote_name(upstream)

  git2r::push(
    git_repo(),
    name = name,
    refspec = paste0("refs/heads/", branch),
    force = force
  )
}

git_branch_pull <- function(branch) {
  repo <- git_repo()
  git2r::fetch(repo, "origin", refspec = branch, verbose = FALSE)
  merge(repo, paste0("origin/", branch), fail = TRUE)
}

git_branch_remote <- function(branch = git_branch_name()) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  upstream <- git2r::branch_get_upstream(branch_obj)
  upstream$name
}

git_branch_track <- function(branch, remote = "origin", remote_branch = branch) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  git2r::branch_set_upstream(branch_obj, paste0(remote, "/", remote_branch))
}
