% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/r.R
\name{use_r}
\alias{use_r}
\alias{use_test}
\title{Create or edit R or test files}
\usage{
use_r(name = NULL, open = rlang::is_interactive())

use_test(name = NULL, open = rlang::is_interactive())
}
\arguments{
\item{name}{Either a name without extension, or \code{NULL} to create the
paired file based on currently open file in the script editor. If
the R file is open, \code{use_test()} will create/open the corresponding
test file; if the test file is open, \code{use_r()} will create/open the
corresponding R file.}

\item{open}{Whether to open the file for interactive editing.}
}
\description{
This pair of functions makes it easy to create paired R and test files,
using the convention that the tests for \code{R/foofy.R} should live
in \code{tests/testhat/test-foofy.R}. You can use them to create new files
from scratch by supplying \code{name}, or if you use RStudio, you can call
to create (or navigate to) the paired file based on the currently open
script.
}
\seealso{
The \href{https://r-pkgs.org/tests.html}{testing} and
\href{https://r-pkgs.org/r.html}{R code} chapters of
\href{https://r-pkgs.org}{R Packages}.
}