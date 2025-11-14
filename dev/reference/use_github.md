# Connect a local repo with GitHub

`use_github()` takes a local project and:

- Checks that the initial state is good to go:

  - Project is already a Git repo

  - Current branch is the default branch, e.g. `main` or `master`

  - No uncommitted changes

  - No pre-existing `origin` remote

- Creates an associated repo on GitHub

- Adds that GitHub repo to your local repo as the `origin` remote

- Makes an initial push to GitHub

- Calls
  [`use_github_links()`](https://usethis.r-lib.org/dev/reference/use_github_links.md),
  if the project is an R package

- Configures `origin/DEFAULT` to be the upstream branch of the local
  `DEFAULT` branch, e.g. `main` or `master`

See below for the authentication setup that is necessary for all of this
to work.

## Usage

``` r
use_github(
  organisation = NULL,
  private = FALSE,
  visibility = c("public", "private", "internal"),
  protocol = git_protocol(),
  host = NULL
)
```

## Arguments

- organisation:

  If supplied, the repo will be created under this organisation, instead
  of the login associated with the GitHub token discovered for this
  `host`. The user's role and the token's scopes must be such that you
  have permission to create repositories in this `organisation`.

- private:

  If `TRUE`, creates a private repository.

- visibility:

  Only relevant for organisation-owned repos associated with certain
  GitHub Enterprise products. The special "internal" `visibility` grants
  read permission to all organisation members, i.e. it's intermediate
  between "private" and "public", within GHE. When specified,
  `visibility` takes precedence over `private = TRUE/FALSE`.

- protocol:

  One of "https" or "ssh"

- host:

  GitHub host to target, passed to the `.api_url` argument of
  [`gh::gh()`](https://gh.r-lib.org/reference/gh.html). If unspecified,
  gh defaults to "https://api.github.com", although gh's default can be
  customised by setting the GITHUB_API_URL environment variable.

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

## Examples

``` r
if (FALSE) { # \dontrun{
pkgpath <- file.path(tempdir(), "testpkg")
create_package(pkgpath)

## now, working inside "testpkg", initialize git repository
use_git()

## create github repository and configure as git remote
use_github()
} # }
```
