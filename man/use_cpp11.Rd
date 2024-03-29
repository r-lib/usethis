% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cpp11.R
\name{use_cpp11}
\alias{use_cpp11}
\title{Use C++ via the cpp11 package}
\usage{
use_cpp11()
}
\description{
Adds infrastructure needed to use the \href{https://cpp11.r-lib.org}{cpp11}
package, a header-only R package that helps R package developers handle R
objects with C++ code:
\itemize{
\item Creates \verb{src/}
\item Adds cpp11 to \code{DESCRIPTION}
\item Creates \code{src/code.cpp}, an initial placeholder \code{.cpp} file
}
}
