pr_use <- function(branch) {
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


pr_push <- function() {
  check_on_branch()
  check_uses_github()
  check_uncommitted_changes()

  done("Pushing to GitHub")
  git2r::push(proj_git_repo(), "origin", paste0("refs/heads/", cur_branch$name))

  # TODO: figure out how to determine if PR already exists
  url <- glue("https://github.com/{github_ower()}/{github_repo()}/compare/pkgman?expand=1")
  view_url(url)
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

