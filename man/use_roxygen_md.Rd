% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/roxygen.R
\name{use_roxygen_md}
\alias{use_roxygen_md}
\title{Use roxygen2 with markdown}
\usage{
use_roxygen_md(overwrite = FALSE)
}
\arguments{
\item{overwrite}{Whether to overwrite an existing \code{Roxygen} field in
\code{DESCRIPTION} with \code{"list(markdown = TRUE)"}.}
}
\description{
If you are already using roxygen2, but not with markdown, you'll need to use
\href{https://roxygen2md.r-lib.org}{roxygen2md} to convert existing Rd expressions
to markdown. The conversion is not perfect, so make sure to check the
results.
}
