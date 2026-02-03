# Exploring badge accessibility

``` r
library(usethis)
```

Various functions in usethis insert a badge into a package’s README
file. A badge consists of an image with information about the package,
which is usually hyperlinked to a location with further details. Here is
a typical badge:

[![badge_example](https://img.shields.io/badge/badge%20label-badge%20message-yellowgreen)](https://shields.io/)

For example, the badge message might be “passing” or “failing”,
reflecting the `R CMD check` status of its current development state,
and then link to the actual log file. Or the badge could display the
current test coverage, as a percentage of lines, and then link to a site
where one can explore test coverage line-by-line.

[![R-CMD-check](https://github.com/r-lib/usethis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/usethis/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/usethis/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/usethis?branch=main)

A key point is that the badge often presents *dynamic* information.

We’d like to improve the user experience for those consuming the README
using assistive technology, such as a screen reader.

There are at least two ways that usethis can influence this:

- The construction of the hyperlinked badge. For example, we control the
  alt text.
- The image itself. We can encourage the badge providers to build
  accessibility into their badge SVGs. If the “native” badge is not
  accessible, usethis can substitute an accessible badge from a 3rd
  party, such as [shields.io](https://shields.io/).

This article is meant to gather badge facts in one place and facilitate
a dialogue with those using assistive technology.

## Markdown image link

usethis currently inserts badges in a special “badge block” in the
README, fenced with HTML comment tags. Within the badge block, each
badge is a hyperlinked image, with alt text. Here is the basic form:

    [![alt_text](http://path/to/the/badge/image)](http://path/to/more/details)

Note that the `alt_text` should be a static label explaining the badge’s
purpose, whereas the dynamic information is baked into the
externally-served image.

usethis definitely controls this `alt_text`, so that is something I’d
like feedback on.

## Badge image

Most badges these days tend to be SVG files, which is fortunate, since
SVGs can carry attributes to support accessibility. We demonstrate this
with a custom badge generated via the [shields.io](https://shields.io/)
web service.

I will request a badge with this URL:

    https://img.shields.io/badge/my__label-my__message-orange

Here it is as a badge, with the hyperlink set to <https://shields.io/>.
The badge is inside an HTML comment block, like usethis does for README
badges. I’ve prefixed every field I can influence with “my”; there are 3
such fields:

1.  The alt text.
2.  The label. This static text appears on the left side of the badge,
    on a grey background, and describes the badge.
3.  The message. This text appears on the right side of the badge, on a
    colored background. This is often the dynamic part, where both the
    color and the text convey a dynamic fact, e.g. “passing” on a green
    background or “failing” on a red background.

[![my_alt_text](https://img.shields.io/badge/my__label-my__message-orange)](https://shields.io/)

Now we inspect the badge SVG. I apologize in advance for the amount of
data displayed here, but it seems good to show one badge in full gory
detail. Later, we will display badge information very selectively.

``` r
library(xml2)
library(purrr)

inspect_badge <- function(badge) {
  badge |>
    read_xml() |>
    as_list() |>
    pluck("svg")
}

inspect_badge("https://img.shields.io/badge/my__label-my__message-orange")
#> $title
#> $title[[1]]
#> [1] "my_label: my_message"
#> 
#> 
#> $linearGradient
#> $linearGradient$stop
#> list()
#> attr(,"offset")
#> [1] "0"
#> attr(,"stop-color")
#> [1] "#bbb"
#> attr(,"stop-opacity")
#> [1] ".1"
#> 
#> $linearGradient$stop
#> list()
#> attr(,"offset")
#> [1] "1"
#> attr(,"stop-opacity")
#> [1] ".1"
#> 
#> attr(,"id")
#> [1] "s"
#> attr(,"x2")
#> [1] "0"
#> attr(,"y2")
#> [1] "100%"
#> 
#> $clipPath
#> $clipPath$rect
#> list()
#> attr(,"width")
#> [1] "144"
#> attr(,"height")
#> [1] "20"
#> attr(,"rx")
#> [1] "3"
#> attr(,"fill")
#> [1] "#fff"
#> 
#> attr(,"id")
#> [1] "r"
#> 
#> $g
#> $g$rect
#> list()
#> attr(,"width")
#> [1] "61"
#> attr(,"height")
#> [1] "20"
#> attr(,"fill")
#> [1] "#555"
#> 
#> $g$rect
#> list()
#> attr(,"x")
#> [1] "61"
#> attr(,"width")
#> [1] "83"
#> attr(,"height")
#> [1] "20"
#> attr(,"fill")
#> [1] "#fe7d37"
#> 
#> $g$rect
#> list()
#> attr(,"width")
#> [1] "144"
#> attr(,"height")
#> [1] "20"
#> attr(,"fill")
#> [1] "url(#s)"
#> 
#> attr(,"clip-path")
#> [1] "url(#r)"
#> 
#> $g
#> $g$text
#> $g$text[[1]]
#> [1] "my_label"
#> 
#> attr(,"aria-hidden")
#> [1] "true"
#> attr(,"x")
#> [1] "315"
#> attr(,"y")
#> [1] "150"
#> attr(,"fill")
#> [1] "#010101"
#> attr(,"fill-opacity")
#> [1] ".3"
#> attr(,"transform")
#> [1] "scale(.1)"
#> attr(,"textLength")
#> [1] "510"
#> 
#> $g$text
#> $g$text[[1]]
#> [1] "my_label"
#> 
#> attr(,"x")
#> [1] "315"
#> attr(,"y")
#> [1] "140"
#> attr(,"transform")
#> [1] "scale(.1)"
#> attr(,"fill")
#> [1] "#fff"
#> attr(,"textLength")
#> [1] "510"
#> 
#> $g$text
#> $g$text[[1]]
#> [1] "my_message"
#> 
#> attr(,"aria-hidden")
#> [1] "true"
#> attr(,"x")
#> [1] "1015"
#> attr(,"y")
#> [1] "150"
#> attr(,"fill")
#> [1] "#010101"
#> attr(,"fill-opacity")
#> [1] ".3"
#> attr(,"transform")
#> [1] "scale(.1)"
#> attr(,"textLength")
#> [1] "730"
#> 
#> $g$text
#> $g$text[[1]]
#> [1] "my_message"
#> 
#> attr(,"x")
#> [1] "1015"
#> attr(,"y")
#> [1] "140"
#> attr(,"transform")
#> [1] "scale(.1)"
#> attr(,"fill")
#> [1] "#fff"
#> attr(,"textLength")
#> [1] "730"
#> 
#> attr(,"fill")
#> [1] "#fff"
#> attr(,"text-anchor")
#> [1] "middle"
#> attr(,"font-family")
#> [1] "Verdana,Geneva,DejaVu Sans,sans-serif"
#> attr(,"text-rendering")
#> [1] "geometricPrecision"
#> attr(,"font-size")
#> [1] "110"
#> 
#> attr(,"width")
#> [1] "144"
#> attr(,"height")
#> [1] "20"
#> attr(,"role")
#> [1] "img"
#> attr(,"aria-label")
#> [1] "my_label: my_message"
#> attr(,"xmlns")
#> [1] "http://www.w3.org/2000/svg"
```

It is my understanding that the two main pieces of metadata are the
`title` and the `aria-label` attribute. Here I reveal just those two
items from the badge:

``` r
inspect_badge <- function(badge) {
  x <- badge |>
    read_xml() |>
    as_list() |>
    pluck("svg")
  list(
    title = pluck(x, "title", 1),
    `aria-label` = pluck(x, attr_getter("aria-label"))
  )
}

inspect_badge("https://img.shields.io/badge/my__label-my__message-orange")
#> $title
#> [1] "my_label: my_message"
#> 
#> $`aria-label`
#> [1] "my_label: my_message"
```

This badge carries the same information in the `title` and in
`aria-label`, which is “my_label: my_message”. I would be interested to
learn more about why the same information is included twice and if that
is a good or bad thing for the screen reader experience.

### shields.io badges are accessible today

One of the reasons I inspected a shields.io badge is that this may
provide a usable alternative for any service whose official badge is not
(yet?) screen-reader-friendly.

The custom badge above is completely static. But shields.io also
supports custom dynamic badges, when the necessary information (label,
message, color) is available from a suitable JSON endpoint. Finally, and
most relevant to usethis, shields.io offers pre-configured dynamic
badges for the most commonly “badged” services, including GitHub Actions
and Codecov.

Here is a shields.io badge for usethis’s `R CMD check` workflow on
GitHub Actions:

[![my_alt_text-R-CMD-check](https://img.shields.io/github/workflow/status/r-lib/usethis/R-CMD-check?label=my_label-R-CMD-check)](https://github.com/r-lib/usethis/actions/workflows/R-CMD-check.yaml)

Again, I am indicating fields I control with `my_alt_text` and
`my_label`, so it’s easier to get feedback on what usethis should do.

Here is the `title` and `aria-label` of the badge above:

``` r
inspect_badge("https://img.shields.io/github/workflow/status/r-lib/usethis/R-CMD-check?label=my_label-R-CMD-check")
#> $title
#> [1] "my_label-R-CMD-check: https://github.com/badges/shields/issues/8671"
#> 
#> $`aria-label`
#> [1] "my_label-R-CMD-check: https://github.com/badges/shields/issues/8671"
```

Now we will take inventory of the main badges inserted by usethis and
where things stand re: accessibility.

## `R CMD check` status

We generally obtain the current `R CMD check` status from a GitHub
Actions workflow.

Here is the official badge provided by GitHub:

[![R-CMD-check](https://github.com/r-lib/usethis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/usethis/actions/workflows/R-CMD-check.yaml)

Here is the `title` and `aria-label` of the badge above:

``` r
inspect_badge("https://github.com/r-lib/usethis/actions/workflows/R-CMD-check.yaml/badge.svg")
#> $title
#> [1] "R-CMD-check.yaml - failing"
#> 
#> $`aria-label`
#> NULL
```

At the time of writing (late December 2021), the badge does not include
such information.

I have requested this in GitHub’s Actions and Packages Feedback forum
and the response from GitHub is encouraging. Hopefully the native badge
will gain improved accessibility early in 2022.

<https://github.com/github/feedback/discussions/8974>

In the meantime, one could use a shields.io badge to report
`R CMD check` status, as demonstrated in the previous section. A
maintainer could do this as a one-off or, if the GitHub badge upgrade is
slow in coming, we could implement it in
[`usethis::use_github_actions_badge()`](https://usethis.r-lib.org/dev/reference/use_github_actions_badge.md).

## Package lifecycle

[`usethis::use_lifecycle_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
declares the developmental stage of a package, using the framework from
<https://lifecycle.r-lib.org/articles/stages.html>. This function
already inserts a shields.io badge:

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

Here is the `title` and `aria-label` of the badge above:

``` r
inspect_badge("https://img.shields.io/badge/lifecycle-stable-brightgreen.svg")
#> $title
#> [1] "lifecycle: stable"
#> 
#> $`aria-label`
#> [1] "lifecycle: stable"
```

It’s possible that usethis should be using a badge “owned” by the
lifecycle package. I think we don’t do so now, because declaring the
lifecycle stage of a whole package does not necessarily imply the need
to take a formal dependency on the lifecycle package, which is usually
what causes badges to be copied into the `man/figures/` directory.

Also, the badges shipped by the lifecycle package are *not* currently
accessible, which is another reason not to use them. But I have opened
an issue about this (<https://github.com/r-lib/lifecycle/issues/117>).
This should be a relatively easy fix, since these are static badges.
Once done, package maintainers would need to update the SVGs that are
stored in `man/figures/`.

## CRAN status

[`usethis::use_cran_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
places a badge that indicates what package version is available on CRAN.
This badge is served by METACRAN (<https://www.r-pkg.org>) and
maintainer Gábor Csárdi has already incorporated `aria-label` into the
badges (in [this
commit](https://github.com/metacran/metacranweb/commit/8287a21e6dc2bc50a2d8a7b5a5a56904ae1d04ff)).
All available badges are listed [here](https://www.r-pkg.org/services).

Here’s the badge placed by
[`usethis::use_cran_badge()`](https://usethis.r-lib.org/dev/reference/badges.md):

[![CRAN
status](https://www.r-pkg.org/badges/version/usethis)](https://CRAN.R-project.org/package=usethis)

Here is the `title` and `aria-label` of the badge above:

``` r
inspect_badge("https://www.r-pkg.org/badges/version/usethis")
#> $title
#> NULL
#> 
#> $`aria-label`
#> [1] "CRAN 3.2.1"
```

At the time of writing (late December 2021), `aria-label` is present,
but `title` is not. I would be interested to know if this is a good
situation for those using a screen reader.

## Code coverage

`usethis::use_coverage(type = c("codecov", "coveralls", ...)` calls the
internal helper `usethis:::use_codecov_badge()` to insert a badge for
either the Codecov or Coveralls service.

Here are examples of those two badges (note that usethis does not use
Coveralls, so I’m using a different package to demo):

[![Codecov test
coverage](https://codecov.io/gh/r-lib/usethis/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/usethis?branch=main)
[![Coveralls test
coverage](https://coveralls.io/repos/github/trinker/sentimentr/badge.svg?branch=master)](https://coveralls.io/github/trinker/sentimentr?branch=master)

Here are the `title` and `aria-label` of those badges::

``` r
inspect_badge("https://codecov.io/gh/r-lib/usethis/branch/main/graph/badge.svg")
#> $title
#> NULL
#> 
#> $`aria-label`
#> NULL

inspect_badge("https://coveralls.io/repos/github/trinker/sentimentr/badge.svg?branch=master")
#> $title
#> NULL
#> 
#> $`aria-label`
#> NULL
```

At the time of writing (late December 2021), neither badge offers a
`title` or `aria-label`.

Here are badges from shields.io for Codecov and Coveralls:

[![Codecov test
coverage](https://img.shields.io/codecov/c/github/r-lib/usethis?label=test%20coverage&logo=codecov)](https://app.codecov.io/gh/r-lib/usethis?branch=main)
[![Coveralls test
coverage](https://coveralls.io/repos/github/trinker/sentimentr/badge.svg?branch=master)](https://img.shields.io/coveralls/github/trinker/sentimentr?logo=coveralls)

Here are the `title` and `aria-label` of the shields.io badges::

``` r
inspect_badge("https://img.shields.io/codecov/c/github/r-lib/usethis?label=test%20coverage&logo=codecov")
#> $title
#> [1] "test coverage: 60%"
#> 
#> $`aria-label`
#> [1] "test coverage: 60%"

inspect_badge("https://img.shields.io/coveralls/github/trinker/sentimentr?logo=coveralls")
#> $title
#> [1] "coverage: 19%"
#> 
#> $`aria-label`
#> [1] "coverage: 19%"
```

## Bioconductor

If a package is on Bioconductor,
[`usethis::use_bioc_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
can be used to insert a badge for its Bioconductor build status.

Here is such a badge:

[![BioC
status](http://www.bioconductor.org/shields/build/release/bioc/biocthis.svg)](https://bioconductor.org/checkResults/release/bioc-LATEST/biocthis)

Here is the `title` and `aria-label` of that badge:

``` r
inspect_badge("http://www.bioconductor.org/shields/build/release/bioc/biocthis.svg")
#> $title
#> NULL
#> 
#> $`aria-label`
#> NULL
```

At the time of writing (late December 2021), the badge does not have a
`title` or `aria-label`.

It’s not immediately clear how to resolve this, but I suspect that
Bioconductor would be receptive to a request to create more accessible
badges.
