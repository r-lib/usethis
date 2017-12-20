# Contributing to {{{package}}}

-   [Prerequisites](#prerequisites)
-   [Package mechanics](#package-mechanics)
    -   [Fork, clone, branch](#fork-clone-branch)
    -   [Establish a baseline](#establish-a-baseline)
    -   [Style](#style)
    -   [Documentation](#documentation)
    -   [Testing](#testing)
    -   [NEWS](#news)
    -   [Committing your changes](#commiting-your-changes)
-   [Making the pull request](#making-the-pull-request)
    -   [Review, revise, repeat](#review-revise-repeat)
-   [Resources](#resources)
-   [Code of Conduct](#code-of-conduct)

This explains how to propose a change to {{{package}}} via a pull request using
Git and Github. 

For more general info about contributing to the tidyverse, see the 
[Resources](#resources) at the end of this document.

## Prerequisites

Before you do a pull request, you should always file an issue and make sure
someone from the tidyverse team agrees that it’s a problem, and is happy with
your basic proposal for fixing it. If you’ve found a bug, first create a minimal
[reprex](https://www.tidyverse.org/help/#reprex).

## Package mechanics

### Fork, clone, branch

The first thing you'll need to do is to fork the 
[{{{package}}} GitHub repo](https://github.com/tidyverse/{{{package}}}), and 
then clone it locally. We recommend that you create a branch for each PR.

### Establish a baseline

Before changing anything, make sure the package still passes `R CMD check`
locally for you.

``` r
# install.packages("devtools")
devtools::check()
```

### Style

Match the existing code style. This means you should follow the tidyverse
style guide (see [Resources](#resources)).
You can also use the [styler](https://CRAN.R-project.org/package=styler) package
to find code which does not adhere to the style guide.

``` r
# install.packages("styler")
styler::style_pkg()
```

Be careful to only make style changes to the code you are contributing. If you
find that there is a lot of code that doesn't meet the style guide, it would be
better to file an issue or a separate PR to fix that first. You can use one of
styler's other [`style_text`](http://styler.r-lib.org/index.html) variants to
limit the scope of your styling.

### Documentation

We use [roxygen2](https://cran.r-project.org/package=roxygen2),
specifically with the [Markdown
syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/markdown.html),
to create `NAMESPACE` and all `.Rd` files. All edits to documentation
should be done in roxygen comments above the associated function or
object.

``` r
# install.packages("devtools")
devtools::document()
```

See the `RoxygenNote` in [DESCRIPTION](DESCRIPTION) for the version of
roxygen2 being used. 

### Testing

We use [testthat](https://cran.r-project.org/package=testthat). Contributions
with test cases are easier to accept. If you are not sure what parts of your
code is covered by tests, run the following to get a local coverage report of
the package so you can see exactly what lines are not covered in the project.

``` r
# install.packages("devtools")
devtools::test_coverage()
```

Before submitting your changes, make sure that the package either still
passes `R CMD check`, or that the warnings and/or notes have not _changed_
as a result of your edits.

### NEWS

Add a bullet to `NEWS.md` with a concise description of the change, if it’s
something a user would want to know when updating the package. The sentence
format should include your GitHub username, and links to relevant issue(s)/
PR(s). We will handle any organization into sub-sections just prior to a
release.

What merits a bullet?

  - Fixing a typo in the docs does not, but it is still awesome and
    deeply appreciated.
  - Fixing a bug or adding a new feature is bullet-worthy.

### Commiting your changes

When you've made your changes, write a clear commit message describing what
you've done. If you've fixed or closed an issue, make sure to include keywords
`closes #44` or `fixes #101` at the end of your commit message (not in its
title) to automatically close the issue when the PR is merged.

## Making the pull request

Pull requests should have descriptive titles to remind reviewers/maintainers
what the PR is about. You can easily view what exact changes you are proposing
using either the Git diff view in RStudio, or the [branch comparison view](https://help.github.com/articles/creating-a-pull-request/) you'll be taken 
to when you go to create a new PR. The PR description should should clearly 
state the motivating need for change. If the PR is related to an issue, provide 
the issue number and slug in the _description_ using auto-linking syntax (e.g.
`#15`).

### Review, revise, repeat

Since tidyverse development happens in waves, the latency period between
submitting your PR and its being reviewed may vary. When a maintainer does
review a contribution, try to address the comments in short order, and be sure
to use the same conventions described with any revision commits.

## Resources

* [Happy Git and GitHub for the useR](http://happygitwithr.com/) by Jenny Bryan.
* [Contribute to the tidyverse](https://www.tidyverse.org/contribute/) covers
several ways to contribute that _don't_ involve writing code.
* [Contributing Code to the Tidyverse](http://www.jimhester.com/2017/08/08/contributing/) 
by Jim Hester.
* [The tidyverse style guide](http://style.tidyverse.org) by Hadley Wickham.
* [dplyr’s `NEWS.md`](https://github.com/tidyverse/dplyr/blob/master/NEWS.md) is
a good source of examples for both content and styling.
* [Closing issues using keywords](https://help.github.com/articles/closing-issues-using-keywords/)
on GitHub.
* [Autolinked references and URLs](https://help.github.com/articles/autolinked-references-and-urls/)
on GitHub.

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
