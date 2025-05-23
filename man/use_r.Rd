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
\item{name}{Either a string giving a file name (without directory) or
\code{NULL} to take the name from the currently open file in RStudio.}

\item{open}{Whether to open the file for interactive editing.}
}
\description{
This pair of functions makes it easy to create paired R and test files,
using the convention that the tests for \code{R/foofy.R} should live
in \code{tests/testthat/test-foofy.R}. You can use them to create new files
from scratch by supplying \code{name}, or if you use RStudio, you can call
to create (or navigate to) the companion file based on the currently open
file. This also works when a test snapshot file is active, i.e. if you're
looking at \verb{tests/testthat/_snaps/foofy.md}, \code{use_r()} or \code{use_test()} take
you to \code{R/foofy.R} or \code{tests/testthat/test-foofy.R}, respectively.
}
\section{Renaming files in an existing package}{


Here are some tips on aligning file names across \verb{R/} and \verb{tests/testthat/}
in an existing package that did not necessarily follow this convention
before.

This script generates a data frame of \verb{R/} and test files that can help you
identify missed opportunities for pairing:

\if{html}{\out{<div class="sourceCode">}}\preformatted{library(fs)
library(tidyverse)

bind_rows(
  tibble(
    type = "R",
    path = dir_ls("R/", regexp = "\\\\.[Rr]$"),
    name = as.character(path_ext_remove(path_file(path))),
  ),
  tibble(
    type = "test",
    path = dir_ls("tests/testthat/", regexp = "/test[^/]+\\\\.[Rr]$"),
    name = as.character(path_ext_remove(str_remove(path_file(path), "^test[-_]"))),
  )
) |>
  pivot_wider(names_from = type, values_from = path) |>
  print(n = Inf)
}\if{html}{\out{</div>}}

The \code{\link[=rename_files]{rename_files()}} function can also be helpful.
}

\examples{
\dontrun{
# create a new .R file below R/
use_r("coolstuff")

# if `R/coolstuff.R` is active in a supported IDE, you can now do:
use_test()

# if `tests/testthat/test-coolstuff.R` is active in a supported IDE, you can
# return to `R/coolstuff.R` with:
use_r()
}
}
\seealso{
\itemize{
\item The \href{https://r-pkgs.org/testing-basics.html}{testing} and
\href{https://r-pkgs.org/code.html}{R code} chapters of
\href{https://r-pkgs.org}{R Packages}.
\item \code{\link[=use_test_helper]{use_test_helper()}} to create a testthat helper file.
}
}
