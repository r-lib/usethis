# Contributing to {{{package}}}

-   [Prerequisites](#prerequisites)
-   [PR Process](#pr-process)
    -   [Fork, clone, branch](#fork-clone-branch)
    -   [Check](#check)
    -   [Style](#style)
    -   [Document](#document)
    -   [Test](#test)
    -   [NEWS](#news)
    -   [Re-check](#re-check)
    -   [Commit](#commit)
    -   [Push and pull](#push-and-pull)
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

## PR process

### Fork, clone, branch

The first thing you'll need to do is to [fork](https://help.github.com/articles/fork-a-repo/) 
the [{{{package}}} GitHub repo](https://github.com/tidyverse/{{{package}}}), and 
then clone it locally. We recommend that you create a branch for each PR.

### Check

Before changing anything, make sure the package still passes `R CMD check`
locally for you. When in doubt, compare your `R CMD check` results with current
results for [{{{package}}} on Travis]({{{travis_url}}}) (checks on Linux and/or 
MacOS) and, if applicable, AppVeyor (checks on Windows). You'll do this again
before you finalize your pull request, but this baseline will make it easier to
pinpoint any problems introduced by your changes.

``` r
devtools::check()
```

### Style

Match the existing code style. This means you should follow the tidyverse 
[style guide](http://style.tidyverse.org). Use the 
[styler](https://CRAN.R-project.org/package=styler) package to apply the style 
guide automatically.


Be careful to only make style changes to the code you are contributing. If you
find that there is a lot of code that doesn't meet the style guide, it would be
better to file an issue or a separate PR to fix that first.

### Document

We use [roxygen2](https://cran.r-project.org/package=roxygen2),
specifically with the [Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/markdown.html),
to create `NAMESPACE` and all `.Rd` files. All edits to documentation
should be done in roxygen comments above the associated function or
object. Then, run `devtools::document()` to rebuild the `NAMESPACE` and `.Rd` 
files.

See the `RoxygenNote` in [DESCRIPTION](DESCRIPTION) for the version of
roxygen2 being used. 

### Test

We use [testthat](https://cran.r-project.org/package=testthat). Contributions
with test cases are easier to accept. If you are not sure what parts of your
code are covered by tests, run the following to get a local coverage report of
the package so you can see exactly what lines are not covered in the project.

``` r
devtools::test_coverage()
```

### NEWS

For user-facing changes, add a bullet to `NEWS.md` that concisely describes
the change. Small tweaks to the documentation do not need a bullet. The format
should include your GitHub username, and links to relevant issue(s)/PR(s), as
seen below.

```md
* `function_name()` followed by brief description of change (#issue-num, @your-github-user-name)
```

### Re-check

Before submitting your changes, make sure that the package either still
passes `R CMD check`, or that the warnings and/or notes have not _changed_
as a result of your edits.

### Commit

When you've made your changes, write a clear commit message describing what
you've done. If you've fixed or closed an issue, make sure to include keywords
(e.g. `fixes #101`) at the end of your commit message (not in its
title) to automatically close the issue when the PR is merged.

### Push and pull

Once you've pushed your commit(s) to a branch in _your_ fork, you're ready to
make the pull request. Pull requests should have descriptive titles to remind
reviewers/maintainers what the PR is about. You can easily view what exact
changes you are proposing using either the [Git diff](http://r-pkgs.had.co.nz/git.html#git-status) 
view in RStudio, or the [branch comparison view](https://help.github.com/articles/creating-a-pull-request/) 
you'll be taken to when you go to create a new PR. If the PR is related to an 
issue, provide the issue number and slug in the _description_ using 
auto-linking syntax (e.g. `#15`).

### Review, revise, repeat

Since tidyverse development happens in waves, the latency period between
submitting your PR and its review may vary. When a maintainer does review
your contribution, be sure to use the same conventions described here with any
revision commits.

## Resources

* [Happy Git and GitHub for the useR](http://happygitwithr.com/) by Jenny Bryan.
* [Contribute to the tidyverse](https://www.tidyverse.org/contribute/) covers
several ways to contribute that _don't_ involve writing code.
* [Contributing Code to the Tidyverse](http://www.jimhester.com/2017/08/08/contributing/) 
by Jim Hester.
* [R packages](http://r-pkgs.had.co.nz/) by Hadley Wickham.
  - [Git and GitHub](http://r-pkgs.had.co.nz/git.html)
  - [Automated checking](http://r-pkgs.had.co.nz/check.html)
  - [Object documentation](http://r-pkgs.had.co.nz/man.html)
  - [Testing](http://r-pkgs.had.co.nz/tests.html)
* [dplyr’s `NEWS.md`](https://github.com/tidyverse/dplyr/blob/master/NEWS.md) is
a good source of examples for both content and styling.
* [Closing issues using keywords](https://help.github.com/articles/closing-issues-using-keywords/)
on GitHub.
* [Autolinked references and URLs](https://help.github.com/articles/autolinked-references-and-urls/)
on GitHub.
* [GitHub Guides: Forking Projects](https://guides.github.com/activities/forking/).

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
