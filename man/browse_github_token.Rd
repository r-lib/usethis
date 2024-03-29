% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/usethis-defunct.R
\name{browse_github_token}
\alias{browse_github_token}
\alias{browse_github_pat}
\alias{github_token}
\alias{git_branch_default}
\title{Defunct GitHub functions}
\usage{
browse_github_token(...)

browse_github_pat(...)

github_token()

git_branch_default()
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#defunct}{\figure{lifecycle-defunct.svg}{options: alt='[Defunct]'}}}{\strong{[Defunct]}}
\itemize{
\item \code{browse_github_token()} and \code{browse_github_pat()} have been replaced by
\code{\link[=create_github_token]{create_github_token()}}.
\item \code{github_token()} has been replaced by \code{\link[gh:gh_token]{gh::gh_token()}}
\item \code{git_branch_default()} has been replaced by \code{\link[=git_default_branch]{git_default_branch()}}.
}
}
\keyword{internal}
