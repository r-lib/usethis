pr_use <- function(branch) {
  check_uses_git()

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

# Helpers -----------------------------------------------------------------

proj_git_repo <- function() {
  git2r::repository(proj_path())
}

proj_git_branch_get <- function() {
  repo <- proj_git_repo()
  branch <- git2r::repository_head(repo)
  if (!git2r::is_branch(cur_branch)) {
    stop("Detached head; can't continue", call. = FALSE)
  }

  branch
}

proj_git_branch_find <- function(branch) {
  repo <- proj_git_repo()
  branches <- git2r::branches(repo, "local")
  Find(function(x) x$name == branch, branches)
}

