# Create a project from a GitHub repo

Creates a new local project and Git repository from a repo on GitHub, by
either cloning or
[fork-and-cloning](https://docs.github.com/en/get-started/quickstart/fork-a-repo).
In the fork-and-clone case, `create_from_github()` also does additional
remote and branch setup, leaving you in the perfect position to make a
pull request with
[`pr_init()`](https://usethis.r-lib.org/dev/reference/pull-requests.md),
one of several [functions for working with pull
requests](https://usethis.r-lib.org/dev/reference/pull-requests.md).

`create_from_github()` works best when your GitHub credentials are
discoverable. See below for more about authentication.

## Usage

``` r
create_from_github(
  repo_spec,
  destdir = NULL,
  fork = NA,
  rstudio = NULL,
  open = rlang::is_interactive(),
  protocol = git_protocol(),
  host = NULL
)
```

## Arguments

- repo_spec:

  A string identifying the GitHub repo in one of these forms:

  - Plain `OWNER/REPO` spec

  - Browser URL, such as `"https://github.com/OWNER/REPO"`

  - HTTPS Git URL, such as `"https://github.com/OWNER/REPO.git"`

  - SSH Git URL, such as `"git@github.com:OWNER/REPO.git"`

- destdir:

  Destination for the new folder, which will be named according to the
  `REPO` extracted from `repo_spec`. Defaults to the location stored in
  the global option `usethis.destdir`, if defined, or to the user's
  Desktop or similarly conspicuous place otherwise.

- fork:

  If `FALSE`, we clone `repo_spec`. If `TRUE`, we fork `repo_spec`,
  clone that fork, and do additional setup favorable for future pull
  requests:

  - The source repo, `repo_spec`, is configured as the `upstream`
    remote, using the indicated `protocol`.

  - The local `DEFAULT` branch is set to track `upstream/DEFAULT`, where
    `DEFAULT` is typically `main` or `master`. It is also immediately
    pulled, to cover the case of a pre-existing, out-of-date fork.

  If `fork = NA` (the default), we check your permissions on
  `repo_spec`. If you can push, we set `fork = FALSE`, If you cannot, we
  set `fork = TRUE`.

- rstudio:

  Initiate an [RStudio
  Project](https://r-pkgs.org/workflow101.html#sec-workflow101-rstudio-projects)?
  Defaults to `TRUE` if in an RStudio session and project has no
  pre-existing `.Rproj` file. Defaults to `FALSE` otherwise (but note
  that the cloned repo may already be an RStudio Project, i.e. may
  already have a `.Rproj` file).

- open:

  If `TRUE`,
  [activates](https://usethis.r-lib.org/dev/reference/proj_activate.md)
  the new project:

  - If using RStudio or Positron, the new project is opened in a new
    session, window, or browser tab, depending on the product (RStudio
    or Positron) and context (desktop or server).

  - Otherwise, the working directory and active project of the current R
    session are changed to the new project.

- protocol:

  One of "https" or "ssh"

- host:

  GitHub host to target, passed to the `.api_url` argument of
  [`gh::gh()`](https://gh.r-lib.org/reference/gh.html). If `repo_spec`
  is a URL, `host` is extracted from that.

  If unspecified, gh defaults to "https://api.github.com", although gh's
  default can be customised by setting the GITHUB_API_URL environment
  variable.

  For a hypothetical GitHub Enterprise instance, either
  "https://github.acme.com/api/v3" or "https://github.acme.com" is
  acceptable.

## Git/GitHub Authentication

Many usethis functions, including those documented here, potentially
interact with GitHub in two different ways:

- Via the GitHub REST API. Examples: create a repo, a fork, or a pull
  request.

- As a conventional Git remote. Examples: clone, fetch, or push.

Therefore two types of auth can happen and your credentials must be
discoverable. Which credentials do we mean?

- A GitHub personal access token (PAT) must be discoverable by the gh
  package, which is used for GitHub operations via the REST API. See
  [`gh_token_help()`](https://usethis.r-lib.org/dev/reference/github-token.md)
  for more about getting and configuring a PAT.

- If you use the HTTPS protocol for Git remotes, your PAT is also used
  for Git operations, such as `git push`. Usethis uses the gert package
  for this, so the PAT must be discoverable by gert. Generally gert and
  gh will discover and use the same PAT. This ability to "kill two birds
  with one stone" is why HTTPS + PAT is our recommended auth strategy
  for those new to Git and GitHub and PRs.

- If you use SSH remotes, your SSH keys must also be discoverable, in
  addition to your PAT. The public key must be added to your GitHub
  account.

Git/GitHub credential management is covered in a dedicated article:
[Managing Git(Hub)
Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html)

## See also

- [`use_github()`](https://usethis.r-lib.org/dev/reference/use_github.md)
  to go the opposite direction, i.e. create a GitHub repo from your
  local repo

- [`git_protocol()`](https://usethis.r-lib.org/dev/reference/git_protocol.md)
  for background on `protocol` (HTTPS vs SSH)

- [`use_course()`](https://usethis.r-lib.org/dev/reference/zip-utils.md)
  to download a snapshot of all files in a GitHub repo, without the need
  for any local or remote Git operations

## Examples

``` r
if (FALSE) { # \dontrun{
create_from_github("r-lib/usethis")

# repo_spec can be a URL
create_from_github("https://github.com/r-lib/usethis")

# a URL repo_spec also specifies the host (e.g. GitHub Enterprise instance)
create_from_github("https://github.acme.com/OWNER/REPO")
} # }
```
