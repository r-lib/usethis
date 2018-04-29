load_all()

# This test file is to be executed in an interactive session. use_github needs
# to create a repo in a github account. You must have a token with write access
# in a repo. Helpers functions will help you clean afterwards.

# TODO : tests for ssh protocol. Only https here.


# Helpers -----------------------------------------------------------------

## Use api to delete if GITHUB token has the correct scope.
## Otherwise, open the setting page of the repo to delete manually
delete_repo <- function(gh_account = gh::gh_whoami(), repo_name = NULL, api_deletion = TRUE) {
  if (!interactive()) stop("Only use interactively", call. = FALSE)
  if (is.null(repo_name)) stop("You can't delete a NULL project...", call. = FALSE)
  if (api_deletion && grepl("delete_repo", gh_account$scopes)) {
    # If the token has the correct rights, delete the repo (after confirmation)
    repo_to_delete <- paste0(gh_account$login, "/", repo_name)
    message("Using Token to delete")
    if(yep("Confirming deletion of ", crayon::red(repo_to_delete), " ?")) {
      gh::gh("DELETE /repos/:username/:pkg", username = gh_account$login, pkg = repo_name)
    }
  } else {
    # Otherwise just open the browser for manual deletion
    view_url(file.path(gh_account$html_url, dummy_pkg_name, "settings"))
  }
  invisible(NULL)
}

# helper for dummy pkg folder with git repository
create_dummy_git_pkg <- function(pkg_path) {
  create_package(pkg_path,
                 fields = list(
                   Title = "Dummy Package to test usethis - remember to remove"),
                 open = FALSE)
  ## need withr because use_git only work in working directory
  withr::with_dir(pkg_path, use_git("Remember to delete this repo"))
}


# Test to execute manually ------------------------------------------------

# Init temporary directory & create dummy package
testdir <- tempfile("testdir")
dir.create(testdir)
dummy_pkg_name <- "testpkg"
dummy_pkg <- file.path(testdir, dummy_pkg_name)

create_dummy_git_pkg(dummy_pkg)

## assumes a gh account is configured
(gh_account <- gh::gh_whoami())

## using https authentification and default auth
use_github(
  organisation = NULL,
  private = FALSE,
  protocol = "https",
  credentials = NULL,
  auth_token = NULL)

# Cleaning

## Delete github repo
delete_repo(gh_account, dummy_pkg_name)
unlink(dummy_pkg, recursive = TRUE)

# without env var
create_dummy_git_pkg(dummy_pkg)

## store my PAT
token <- gh_token()

## make my PAT unavailable via env vars
Sys.unsetenv(c("GITHUB_PAT", "GITHUB_TOKEN"))
gh::gh_whoami()

## using https authentification
## No default auth - expect error
use_github(protocol = "https")
## expect success when provide auth
use_github(protocol = "https", auth_token = token)

## Delete github repo
delete_repo(gh_account, dummy_pkg_name)
unlink(dummy_pkg, recursive = TRUE)
