pr_create <- function(branch) {
  check_uses_github()

  cur_branch <- proj_git_branch_get()
  if (cur_branch$name == branch) {
    return(invisible(TRUE))
  }

  pr_branch <- proj_git_branch_find(branch)
  if (is.null(pr_branch)) {
    if (cur_branch$name != "master") {
      if (nope("Start pull-request from non-master branch?")) {
        return(invisible(FALSE))
      }
    }

    done("Creating branch {value(branch)}")
    head <- git2r::commits(repo, n = 1)[[1]]
    pr_branch <- git2r::branch_create(head, branch)
  }

  done("Switching to branch {value(branch)}")
  git2r::checkout(pr_branch)

  invisible()
}

pr_push <- function(force = FALSE) {
  check_on_branch()
  check_uses_github()
  check_uncommitted_changes()

  done("Pushing changes to GitHub PR")
  git2r::push(
    object = proj_git_repo(),
    name = "origin",
    refspec = paste0("refs/heads/", cur_branch$name),
    force = force
  )
}

pr_pull <- function() {
  check_on_branch()
  check_uses_github()
  check_uncommitted_changes()

  done("Pulling changes from GitHub PR")
  git2r::pull(repo)
}

pr_update <- function() {
  done("Fetching master branch from GitHub")
  git2r::fetch(repo, "origin", refspec = "refs/head/master")

  done("Merging master branch")
  out <- merge(repo, "origin/master")
  if (out$conflicts) {
    todo("Merge conflicts found. Fix by hand, then try again.")
    return(invisible(FALSE))
  }

  pr_push()

  invisible(TRUE)
}

pr_view <- function() {
  view_url(pr_url())
}

pr_url <- function() {
  repo <- proj_git_repo()
  branch <- proj_git_branch_get()$name

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
    done("Create PR")
    url <- glue("https://github.com/{github_owner()}/{github_repo()}/compare/{branch}")
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

# Helpers -----------------------------------------------------------------

check_on_branch <- function() {
  cur_branch <- proj_git_branch_get()
  if (cur_branch$name == "master") {
    stop("Currently on master branch. Do you need to call `pr_use()` first?", call. = FALSE)
  }
}

proj_git_repo <- function() {
  check_uses_git()
  git2r::repository(proj_path())
}

proj_git_branch_get <- function() {
  repo <- proj_git_repo()
  branch <- git2r::repository_head(repo)
  if (!git2r::is_branch(branch)) {
    stop("Detached head; can't continue", call. = FALSE)
  }

  branch
}

proj_git_branch_find <- function(branch) {
  repo <- proj_git_repo()
  branches <- git2r::branches(repo, "local")
  Find(function(x) x$name == branch, branches)
}

