# Contributing to {{{package}}}


## What is this?

A `CONTRIBUTING.md` document (such as this one) has instructions for
contributing to the project. These are guidelines the maintainers would
like contributors to adhere to, and exist to make the process flow more
smoothly.

As a contributor you should try to make accepting your code as easy as
you can, following the contributing docs greatly increases the chance
your contribution will be accepted.

Some common tidyverse conventions are

  - Add a bullet to `NEWS.md` for each change referencing the issue
    number and your GitHub username.
  - Add `Closes #123` at the end of your commit message to automatically
    close the issue with the PR is merged.
  - Document functions with
    [roxygen2](https://cran.r-project.org/web/packages/roxygen2/) and be
    sure to run `devtools::document()` before submitting.

## Prerequisites

  - For this guide to make sense, you’ll need to be acquainted with Git
    and GitHub. If you are not, see [Happy Git and GitHub for the
    useR](http://happygitwithr.com/) by Jenny Bryan.

  - Before you do a pull request, you should always file an issue and
    make sure someone from the tidyverse team agrees that it’s a
    problem, and is happy with your basic proposal for fixing it. If
    you’ve found a bug, first create a minimal
    [reprex](https://www.tidyverse.org/help/#reprex). We don’t want you
    to spend a bunch of time on something that we don’t think is a good
    idea.

There are lots of ways to contribute *other* than by writing code. See
[Contribute to the tidyverse](https://www.tidyverse.org/contribute/) for
more on this.

## Making a pull request - overview

  - When in doubt, discuss in an issue before doing lots of work.
  - Use GitHub to fork and clone the package repo, and a branching
    workflow to make your changes.
  - Uphold the design principles and package mechanics outlined below.
  - Make sure the package still passes `R CMD check` locally for you.
    It’s a good idea to do that before you touch anything, so you have
    a ***baseline***.
  - Match the existing code style. For this purpose, you should follow
    the tidyverse style guide <http://style.tidyverse.org>.
  - Update the documentation source, if your PR changes any behavior. We
    use [**roxygen2**](https://cran.r-project.org/package=roxygen2), so
    you must edit the roxygen comments above the function; never edit
    `NAMESPACE` or `.Rd` files by hand.
  - Do not update the pkgdown-created website, i.e. the files generated
    below `docs/`.
      - To update the roxygen documentation *without* changing the
        pkgdown site, you can run `devtools::document()`.

### Style

For tidyverse projects read the [Style
Guide](http://style.tidyverse.org) and use the
[lintr](https://cran.r-project.org/package=lintr) package to find code
which does not adhere to the style guide.

``` r
# install.packages("lintr")
lintr::lint_package()
```

Remember to include style changes only in code you are contributing.

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
roxygen2 being used. It’s nice if a pull request includes updated
documentation, but a good reason to NOT `document()` is if you have a
different version of roxygen2 installed and that sprays minor formatting
changes across `.Rd` files that have nothing to do with the PR.

### Testing

We use [testthat](https://cran.r-project.org/package=testthat).
Contributions with test cases are easier to accept because the tests
ensure the code does what it intends to do and nothing else. Without
tests the maintainer needs to check the new functionality by hand, a
burden you can lessen or remove by including tests. If you are not sure
what parts of your code is covered by tests
[covr](https://cran.r-project.org/package=covr) is a great tool to use
before submission. Just run the following to get a local coverage report
of the package so you can see exactly what lines are not covered in the
project.

``` r
# install.packages("covr")
co <- covr::package_coverage()
covr::report(co)
```

Before submitting your changes, make sure that the package either still
passes `R CMD check`, or that the warnings and/or notes have not changed
as a result of your edits.

### The Pull Request

Your pull request should clearly and concisely state the motivating the
need for change. Each change and each PR) should correspond to a branch.
The best way to check exactly what changes you are proposing is to use
`git diff` prior to submitting your contribution. This will ensure it
contains only the changes necessary for the new functionality.

If the PR is related to an issue, link to it in the description, with
[the `#15`
syntax](https://help.github.com/articles/autolinked-references-and-urls/)
and the issue slug for context. If the PR is meant to close an issue,
make sure one of the commit messages includes [text like `closes #44` or
`fixes
#101`](https://help.github.com/articles/closing-issues-using-keywords/).
Provide the issue number and slug in the description, even if the issue
is mentioned in the title, because auto-linking does not work in the PR
title.

  - GOOD PR title: *“Obtain user’s intent via mind-reading; fixes
    \#86”.*
  - BAD PR title: *“Fixes \#1043”.* Please remind us all what issue
    \#1043 is about\!
  - BAD PR title: *“Something about \#345”.* This will not actually
    close issue \#345 upon merging.

Add a bullet to `NEWS.md` with a concise description of the change, if
it’s something a user would want to know when updating the package.
[dplyr’s
`NEWS.md`](https://github.com/tidyverse/dplyr/blob/master/NEWS.md) is a
good source of examples. Note the sentence format, the inclusion of
GitHub username, and links to relevant issue(s)/PR(s). We will handle
any organization into sub-sections just prior to a release.

What merits a bullet?

  - Fixing a typo in the docs does not, but it is still awesome and
    deeply appreciated.
  - Fixing a bug or adding a new feature is bullet-worthy.

When a maintainer does review a contribution, try to address the
comments in short order, your changes are much more likely to be
accepted if they are addressed in the next day than the next month.

## On contributing

### View contributing as a relationship, not a transaction

The best way to be successful contributing to open source projects is to
do so repeatedly. This means cultivating trust between yourself and the
maintainer by multiple successful contributions. After a series of
smaller contributions the maintainer will be much more willing to review
and accept more substantial changes. As with any relationship being
polite and considerate throughout will go a long way to improve trust.
If you instead view the contribution as a solitary transaction to add
your pet feature you are much less likely to be successful.

### Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

#### Further reading

This document has been largely inspired by Jenny
Bryan’s [googledrive](http://googledrive.tidyverse.org/)
[`CONTRIBUTING.md`](https://github.com/tidyverse/googledrive/blob/master/CONTRIBUTING.md),
Hadley Wickham’s [Contributing to ggplot2
development](https://github.com/tidyverse/ggplot2/blob/92666ca8dd4cb5f96cbfcd4dcfcf157b599a6048/CONTRIBUTING.md),
and Jim Hester’s [Contributing Code to the
Tidyverse](http://www.jimhester.com/2017/08/08/contributing/), all of
which are worth reading in their own right.
