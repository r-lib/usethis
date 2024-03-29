% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/git.R
\name{use_git_ignore}
\alias{use_git_ignore}
\title{Tell Git to ignore files}
\usage{
use_git_ignore(ignores, directory = ".")
}
\arguments{
\item{ignores}{Character vector of ignores, specified as file globs.}

\item{directory}{Directory relative to active project to set ignores}
}
\description{
Tell Git to ignore files
}
\seealso{
Other git helpers: 
\code{\link{use_git}()},
\code{\link{use_git_config}()},
\code{\link{use_git_hook}()}
}
\concept{git helpers}
