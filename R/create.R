#' Create a package or project
#'
#' @description
#' These functions create an R project:
#'   * `create_package()` creates an R package
#'   * `create_project()` creates a non-package project, i.e. a data analysis
#'   project
#'
#' Both functions can be called on an existing project; you will be asked before
#' any existing files are changed.
#'
#' @inheritParams use_description
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param roxygen Do you plan to use roxygen2 to document your package?
#' @param rstudio If `TRUE`, calls [use_rstudio()] to make the new package or
#'   project into an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects).
#'    If `FALSE` and a non-package project, a sentinel `.here` file is placed so
#'   that the directory can be recognized as a project by the
#'   [here](https://here.r-lib.org) or
#'   [rprojroot](https://rprojroot.r-lib.org) packages.
#' @param open If `TRUE`, [activates][proj_activate()] the new project:
#'
#'   * If RStudio desktop, the package is opened in a new session.
#'   * If on RStudio server, the current RStudio project is activated.
#'   * Otherwise, the working directory and active project is changed.
#'
#' @return Path to the newly created project or package, invisibly.
#' @seealso [create_tidy_package()] is a convenience function that extends
#'   `create_package()` by immediately applying as many of the tidyverse
#'   development conventions as possible.
#' @export
create_package <- function(path,
                           fields = list(),
                           rstudio = rstudioapi::isAvailable(),
                           roxygen = TRUE,
                           check_name = TRUE,
                           open = rlang::is_interactive()) {
  path <- user_path_prep(path)
  check_path_is_directory(path_dir(path))

  name <- path_file(path_real(path))
  if (check_name) {
    check_package_name(name)
  }
  check_not_nested(path_dir(path), name)

  create_directory(path)
  old_project <- proj_set(path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  use_directory("R")
  use_description(fields, check_name = FALSE, roxygen = roxygen)
  use_namespace(roxygen = roxygen)

  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(path)) {
      # Working directory/active project changed; so don't undo on exit
      on.exit()
    }
  }

  invisible(proj_get())
}

#' @export
#' @rdname create_package
create_project <- function(path,
                           rstudio = rstudioapi::isAvailable(),
                           open = rlang::is_interactive()) {
  path <- user_path_prep(path)
  name <- path_file(path)
  check_not_nested(path_dir(path), name)

  create_directory(path)
  old_project <- proj_set(path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  use_directory("R")

  if (rstudio) {
    use_rstudio()
  } else {
    ui_done("Writing a sentinel file {ui_path('.here')}")
    ui_todo("Build robust paths within your project via {ui_code('here::here()')}")
    ui_todo("Learn more at <https://here.r-lib.org>")
    file_create(proj_path(".here"))
  }

  if (open) {
    if (proj_activate(path)) {
      # Working directory/active project changed; so don't undo on exit
      on.exit()
    }
  }

  invisible(proj_get())
}

#' Create a project from a GitHub repo
#'
#' Creates a new local Git repository from a repository on GitHub. It is highly
#' recommended that you pre-configure or pass a GitHub personal access token
#' (PAT), which is facilitated by [browse_github_token()]. In particular, a PAT
#' is required in order for `create_from_github()` to do ["fork and
#' clone"](https://help.github.com/articles/fork-a-repo/). It is also required
#' by [use_github()], which connects existing local projects to GitHub.
#'
#' @seealso [use_github()] for GitHub setup advice. [git_protocol()] and
#'   [git_credentials()] for background on `protocol` and `credentials`.
#'   [use_course()] for one-time download of all files in a Git repo, without
#'   any local or remote Git operations.
#'
#' @section Using SSH Keys on Windows:
#' If you are a Windows user who connects to GitHub using SSH, as opposed to
#' HTTPS, you may need to explicitly specify the paths to your keys and register
#' this credential in the current R session. This helps if git2r, which usethis
#' uses for Git operations, does not automatically find your keys or handle your
#' passphrase.
#'
#' In the snippet below, do whatever is necessary to make the paths correct,
#' e.g., replace `<USERNAME>` with your Windows username. Omit the `passphrase`
#' part if you don't have one. Replace `<OWNER/REPO>` with the appropriate
#' GitHub specification. You get the idea.
#'
#' ```
#' creds <- git2r::cred_ssh_key(
#'   publickey  = "C:/Users/<USERNAME>/.ssh/id_rsa.pub",
#'   privatekey = "C:/Users/<USERNAME>/.ssh/id_rsa",
#'   passphrase = character(0)
#' )
#' use_git_protocol("ssh")
#' use_git_credentials(credentials = creds)
#'
#' create_from_github(
#'   repo_spec = "<OWNER/REPO>",
#'   ...
#' )
#' ```
#'
#' @inheritParams create_package
#' @param repo_spec GitHub repo specification in this form: `owner/repo`. The
#'   `repo` part will be the name of the new local repo.
#' @inheritParams use_course
#' @param fork If `TRUE`, we create and clone a fork. If `FALSE`, we clone
#'   `repo_spec` itself. Will be set to `FALSE` if no `auth_token` (a.k.a. PAT)
#'   is provided or preconfigured. Otherwise, defaults to `FALSE` if you can
#'   push to `repo_spec` and `TRUE` if you cannot. In the case of a fork, the
#'   original target repo is added to the local repo as the `upstream` remote,
#'   using the preferred `protocol`. The `master` branch is set to track
#'   `upstream/master` and is immediately pulled, which matters in the case of a
#'   pre-existing, out-of-date fork.
#' @param rstudio Initiate an [RStudio
#'   Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)?
#'    Defaults to `TRUE` if in an RStudio session and project has no
#'   pre-existing `.Rproj` file. Defaults to `FALSE` otherwise.
#' @inheritParams use_github
#'
#' @export
#' @examples
#' \dontrun{
#' create_from_github("r-lib/usethis")
#' }
create_from_github <- function(repo_spec,
                               destdir = NULL,
                               fork = NA,
                               rstudio = NULL,
                               open = rlang::is_interactive(),
                               protocol = git_protocol(),
                               credentials = NULL,
                               auth_token = github_token(),
                               host = NULL) {
  destdir <- user_path_prep(destdir %||% conspicuous_place())
  check_path_is_directory(destdir)

  owner <- spec_owner(repo_spec)
  repo <- spec_repo(repo_spec)
  check_not_nested(destdir, repo)

  repo_path <- path(destdir, repo)
  create_directory(repo_path)
  check_directory_is_empty(repo_path)

  auth_token <- check_github_token(auth_token, allow_empty = TRUE)

  gh <- function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      .token = auth_token,
      .api_url = host
    )
  }

  repo_info <- gh("GET /repos/:owner/:repo", owner = owner, repo = repo)

  fork <- rationalize_fork(fork, repo_info, auth_token)
  if (fork) {
    ## https://developer.github.com/v3/repos/forks/#create-a-fork
    ui_done("Forking {ui_value(repo_info$full_name)}")
    upstream_url <- switch(
      protocol,
      https = repo_info$clone_url,
      ssh = repo_info$ssh_url
    )
    repo_info <- gh(
      "POST /repos/:owner/:repo/forks",
      owner = owner, repo = repo
    )
  }

  origin_url <- switch(
    protocol,
    https = repo_info$clone_url,
    ssh = repo_info$ssh_url
  )

  ui_done("Cloning repo from {ui_value(origin_url)} into {ui_value(repo_path)}")
  credentials <- credentials %||% git_credentials(protocol, auth_token)
  git2r::clone(
    origin_url,
    repo_path,
    credentials = credentials,
    progress = FALSE
  )
  old_project <- proj_set(repo_path, force = TRUE)
  on.exit(proj_set(old_project), add = TRUE)

  if (fork) {
    r <- git2r::repository(proj_get())
    ui_done("Adding {ui_value('upstream')} remote: {ui_value(upstream_url)}")
    git2r::remote_add(r, "upstream", upstream_url)
    pr_pull_upstream()
    ui_done(
      "
      Setting remote tracking branch for local {ui_value('master')} branch to \\
      {ui_value('upstream/master')}
      "
    )
    git2r::branch_set_upstream(git2r::repository_head(r), "upstream/master")
    config_key <- glue("remote.upstream.created-by")
    git_config_set(config_key, "usethis::create_from_github")
  }

  rstudio <- rstudio %||% rstudioapi::isAvailable()
  rstudio <- rstudio && !is_rstudio_project(proj_get())
  if (rstudio) {
    use_rstudio()
  }

  if (open) {
    if (proj_activate(repo_path)) {
      # Working directory/active project changed; so don't undo on exit
      on.exit()
    }
  }

  invisible(proj_get())
}

# creates a backdoor we can exploit in tests
allow_nested_project <- function() FALSE

check_not_nested <- function(path, name) {
  if (!possibly_in_proj(path)) {
    return(invisible())
  }

  # we mock this in a few tests, to allow a nested project
  if (allow_nested_project()) {
    return()
  }

  ui_line(
    "New project {ui_value(name)} is nested inside an existing project \\
    {ui_path(path)}, which is rarely a good idea.
    If this is unexpected, the here package has a function, \\
    {ui_code('here::dr_here()')} that reveals why {ui_path(path)} \\
    is regarded as a project."
  )
  if (ui_nope("Do you want to create anyway?")) {
    ui_stop("Aborting project creation.")
  }
  invisible()
}

rationalize_fork <- function(fork, repo_info, auth_token) {
  have_token <- have_github_token(auth_token)
  can_push <- isTRUE(repo_info$permissions$push)
  repo_owner <- repo_info$owner$login
  user <- if (have_token) github_user(auth_token)[["login"]]

  if (is.na(fork)) {
    fork <- have_token && !can_push
  }

  if (fork && !have_token) {
    ## throw the usual error for bad/missing token
    check_github_token(auth_token)
  }

  if (fork && identical(user, repo_owner)) {
    ui_stop(
      "Repo {ui_value(repo_info$full_name)} is owned by user \\
      {ui_value(user)}. Can't fork."
    )
  }

  fork
}
