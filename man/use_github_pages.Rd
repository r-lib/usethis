% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/github-pages.R
\name{use_github_pages}
\alias{use_github_pages}
\title{Configure a GitHub Pages site}
\usage{
use_github_pages(branch = "gh-pages", path = "/", cname = NA)
}
\arguments{
\item{branch, path}{Branch and path for the site source. The default of
\code{branch = "gh-pages"} and \code{path = "/"} reflects strong GitHub support for
this configuration: when a \code{gh-pages} branch is first created, it is
\emph{automatically} published to Pages, using the source found in \code{"/"}. If a
\code{gh-pages} branch does not yet exist on the host, \code{use_github_pages()}
creates an empty, orphan remote branch.

The most common alternative is to use the repo's default branch, coupled
with \code{path = "/docs"}. It is the user's responsibility to ensure that this
\code{branch} pre-exists on the host.

Note that GitHub does not support an arbitrary \code{path} and, at the time of
writing, only \code{"/"} or \code{"/docs"} are accepted.}

\item{cname}{Optional, custom domain name. The \code{NA} default means "don't set
or change this", whereas a value of \code{NULL} removes any previously
configured custom domain.

Note that this \emph{can} add or modify a CNAME file in your repository. If you
are using Pages to host a pkgdown site, it is better to specify its URL in
the pkgdown config file and let pkgdown manage CNAME.}
}
\value{
Site metadata returned by the GitHub API, invisibly
}
\description{
Activates or reconfigures a GitHub Pages site for a project hosted on GitHub.
This function anticipates two specific usage modes:
\itemize{
\item Publish from the root directory of a \code{gh-pages} branch, which is assumed to
be only (or at least primarily) a remote branch. Typically the \code{gh-pages}
branch is managed by an automatic "build and deploy" job, such as the one
configured by \code{\link[=use_github_action]{use_github_action("pkgdown")}}.
\item Publish from the \code{"/docs"} directory of a "regular" branch, probably the
repo's default branch. The user is assumed to have a plan for how they will
manage the content below \code{"/docs"}.
}
}
\examples{
\dontrun{
use_github_pages()
use_github_pages(branch = git_default_branch(), path = "/docs")
}
}
\seealso{
\itemize{
\item \code{\link[=use_pkgdown_github_pages]{use_pkgdown_github_pages()}} combines \code{use_github_pages()} with other
functions to fully configure a pkgdown site
\item \url{https://docs.github.com/en/pages}
\item \url{https://docs.github.com/en/rest/pages}
}
}
