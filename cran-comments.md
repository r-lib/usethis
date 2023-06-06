## R CMD check results

0 errors | 0 warnings | 1 note

Maintainer's email address is changing from jenny@rstudio.com to jenny@posit.co.

## revdepcheck results

We checked 178 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 2 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

### New problems

* exampletestr
  This package has been using usethis to create a path for a message that goes
  through an intermediate stage where the path doesn't make sense.
  Basically `/path/to/whatever` briefly becomes `/path/to/path/to/whatever`.
  This worked in the past, because the path was then re-processed in a way that
  cancelled out the mistake, i.e. `/path/to/path/to/whatever` was restored to
  `/path/to/whatever`.
  However, usethis now errors for nonsensical paths, like
  `/path/to/path/to/whatever`.
  We've made a pull request to eliminate the unnecessary maneuver.
  This only affects a message, not the functionality of the package.
  https://github.com/rorynolan/exampletestr/pull/12

* fusen
  This package was making use of an unexported function that has been removed.
  We've made a pull request with a more robust way to achieve the intent:
  https://github.com/ThinkR-open/fusen/pull/205

