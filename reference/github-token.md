# Get help with GitHub personal access tokens

A [personal access
token](https://docs.github.com/articles/creating-a-personal-access-token-for-the-command-line)
(PAT) is needed for certain tasks usethis does via the GitHub API, such
as creating a repository, a fork, or a pull request. If you use HTTPS
remotes, your PAT is also used when interacting with GitHub as a
conventional Git remote. These functions help you get and manage your
PAT:

- `gh_token_help()` guides you through token troubleshooting and setup.

- `create_github_token()` opens a browser window to the GitHub form to
  generate a PAT, with suggested scopes pre-selected. It also offers
  advice on storing your PAT.

- [`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
  helps you register your PAT with the Git credential manager used by
  your operating system. Later, other packages, such as usethis, gert,
  and gh can automatically retrieve that PAT and use it to work with
  GitHub on your behalf.

Usually, the first time the PAT is retrieved in an R session, it is
cached in an environment variable, for easier reuse for the duration of
that R session. After initial acquisition and storage, all of this
should happen automatically in the background. GitHub is encouraging the
use of PATs that expire after, e.g., 30 days, so prepare yourself to
re-generate and re-store your PAT periodically.

Git/GitHub credential management is covered in a dedicated article:
[Managing Git(Hub)
Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html)

## Usage

``` r
create_github_token(
  scopes = c("repo", "user", "gist", "workflow"),
  description = "DESCRIBE THE TOKEN'S USE CASE",
  host = NULL
)

gh_token_help(host = NULL)
```

## Arguments

- scopes:

  Character vector of token scopes, pre-selected in the web form. Final
  choices are made in the GitHub form. Read more about GitHub API scopes
  at
  <https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/>.

- description:

  Short description or nickname for the token. You might (eventually)
  have multiple tokens on your GitHub account and a label can help you
  keep track of what each token is for.

- host:

  GitHub host to target, passed to the `.api_url` argument of
  [`gh::gh()`](https://gh.r-lib.org/reference/gh.html). If unspecified,
  gh defaults to "https://api.github.com", although gh's default can be
  customised by setting the GITHUB_API_URL environment variable.

  For a hypothetical GitHub Enterprise instance, either
  "https://github.acme.com/api/v3" or "https://github.acme.com" is
  acceptable.

## Value

Nothing

## Details

`create_github_token()` has previously gone by some other names:
`browse_github_token()` and `browse_github_pat()`.

## See also

[`gh::gh_whoami()`](https://gh.r-lib.org/reference/gh_whoami.html) for
information on an existing token and
[`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
and
[`gitcreds::gitcreds_get()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
for a secure way to store and retrieve your PAT.

## Examples

``` r
if (FALSE) { # \dontrun{
create_github_token()
} # }
if (FALSE) { # \dontrun{
gh_token_help()
} # }
```
