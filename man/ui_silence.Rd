% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-ui.R
\name{ui_silence}
\alias{ui_silence}
\title{Suppress usethis's messaging}
\usage{
ui_silence(code)
}
\arguments{
\item{code}{Code to execute with usual UI output silenced.}
}
\value{
Whatever \code{code} returns.
}
\description{
Execute a bit of code without usethis's normal messaging.
}
\examples{
# compare the messaging you see from this:
browse_github("usethis")
# vs. this:
ui_silence(
  browse_github("usethis")
)
}
