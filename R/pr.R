pr_init <- function(branch) {
  check_uses_github()
  check_branch_current("master")

  if (!git_branch_exists(branch)) {
    if (cur_branch != "master") {
      if (nope("Create local PR branch with non-master parent?")) {
        return(invisible(FALSE))
      }
    }

    done("Creating local PR branch {value(branch)}")
    git_branch_create(branch)
  }

  if (is.null(git_branch_remote(branch))) {
    done("Tracking remote PR branch")
    git_branch_track(branch)
  }

  if (git_branch_name() == branch) {
    done("Switching to branch {value(branch)}")
    git2r::checkout(repo, branch)
  }

  todo("Use {code('pr_push()')} to create PR")
  invisible()
}

pr_push <- function(force = FALSE) {
  check_uses_github()
  check_branch_not_master()
  check_branch_current()
  check_uncommitted_changes()

  done("Pushing changes to GitHub PR")
  git_branch_push(force = force)

  # Prompt to create on first push
  url <- pr_url()
  if (is.null(url)) {
    pr_create_gh()
  } else {
    done("View PR at {value(url)}")
  }
}

pr_pull <- function() {
  check_uses_github()
  check_branch_not_master()
  check_uncommitted_changes()

  done("Pulling changes from GitHub PR")
  git2r::pull(repo)
}

pr_view <- function() {
  url <- pr_url()
  if (is.null(url)) {
    pr_create()
  } else {
    view_url(pr_url())
  }
}

pr_create_gh <- function() {
  owner <- github_owner()
  repo <- github_repo()
  name <- git_branch_name()

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

  stop(
    glue::glue("
      Currently on master branch.
      Do you need to call {code('pr_init()')} first?"
    ),
    call. = FALSE
  )
}

check_branch_current <- function(branch = git_branch_name()) {
  done("Checking that {branch} branch is up to date")
  diff <- git_branch_compare(branch)

  if (diff[[2]] == 0) {
    return()
  }

  stop(
    glue::glue(
      "master branch is out of date.
      Please resolve (somehow) before continuing.
      "
    ),
    call. = FALSE
  )
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
  git2r::branch_create(proj_git_commit(commit), branch)
}

git_branch_compare <- function(branch = git_branch_name()) {
  repo <- git_repo()
  git2r::fetch(repo, "origin", refspec = branch)
  git2r::ahead_behind(
    git_commit_find(branch),
    git_commit_find(paste0("origin/", branch))
  )
}

git_branch_push <- function(branch = git_branch_name(), force = FALSE) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  git2r::push(branch_obj)
}

git_branch_pull <- function(branch) {
  git2r::fetch(repo, "origin", refspec = branch)
  merge(repo, paste0("origin/", branch), fail = TRUE)
}

git_branch_remote <- function(branch = git_branch_name()) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  upstream <- git2r::branch_get_upstream(branch_obj)
  upstream$name
}

git_branch_track <- function(branch) {
  branch_obj <- git2r::branches(git_repo())[[branch]]
  git2r::branch_set_upstream(branch_obj, paste0("origin/", branch))
}
