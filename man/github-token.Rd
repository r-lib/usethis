% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/github_token.R
\name{github-token}
\alias{github-token}
\alias{create_github_token}
\alias{gh_token_help}
\title{Get help with GitHub personal access tokens}
\usage{
create_github_token(
  scopes = c("repo", "user", "gist", "workflow"),
  description = "DESCRIBE THE TOKEN'S USE CASE",
  host = NULL
)

gh_token_help(host = NULL)
}
\arguments{
\item{scopes}{Character vector of token scopes, pre-selected in the web form.
Final choices are made in the GitHub form. Read more about GitHub API
scopes at
\url{https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/}.}

\item{description}{Short description or nickname for the token. You might
(eventually) have multiple tokens on your GitHub account and a label can
help you keep track of what each token is for.}

\item{host}{GitHub host to target, passed to the \code{.api_url} argument of
\code{\link[gh:gh]{gh::gh()}}. If unspecified, gh defaults to "https://api.github.com",
although gh's default can be customised by setting the GITHUB_API_URL
environment variable.

For a hypothetical GitHub Enterprise instance, either
"https://github.acme.com/api/v3" or "https://github.acme.com" is
acceptable.}
}
\value{
Nothing
}
\description{
A \href{https://docs.github.com/articles/creating-a-personal-access-token-for-the-command-line}{personal access token}
(PAT) is needed for certain tasks usethis does via the GitHub API, such as
creating a repository, a fork, or a pull request. If you use HTTPS remotes,
your PAT is also used when interacting with GitHub as a conventional Git
remote. These functions help you get and manage your PAT:
\itemize{
\item \code{gh_token_help()} guides you through token troubleshooting and setup.
\item \code{create_github_token()} opens a browser window to the GitHub form to
generate a PAT, with suggested scopes pre-selected. It also offers advice
on storing your PAT.
\item \code{gitcreds::gitcreds_set()} helps you register your PAT with the Git
credential manager used by your operating system. Later, other packages,
such as usethis, gert, and gh can automatically retrieve that PAT and use
it to work with GitHub on your behalf.
}

Usually, the first time the PAT is retrieved in an R session, it is cached in
an environment variable, for easier reuse for the duration of that R session.
After initial acquisition and storage, all of this should happen
automatically in the background. GitHub is encouraging the use of PATs that
expire after, e.g., 30 days, so prepare yourself to re-generate and re-store
your PAT periodically.

Git/GitHub credential management is covered in a dedicated article: \href{https://usethis.r-lib.org/articles/articles/git-credentials.html}{Managing Git(Hub) Credentials}
}
\details{
\code{create_github_token()} has previously gone by some other names:
\code{browse_github_token()} and \code{browse_github_pat()}.
}
\examples{
\dontrun{
create_github_token()
}
\dontrun{
gh_token_help()
}
}
\seealso{
\code{\link[gh:gh_whoami]{gh::gh_whoami()}} for information on an existing token and
\code{gitcreds::gitcreds_set()} and \code{gitcreds::gitcreds_get()} for a secure way
to store and retrieve your PAT.
}
