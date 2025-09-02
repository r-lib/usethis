## revdepcheck results

We checked 260 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 2 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

### New problems
(This reports the first line of each new failure)

* badger
  checking dependencies in R code ... WARNING

  This package was using a function that was deprecated, with a
  warning, in usethis v2.1.0, released 2021-10-17. There was also
  an existing GitHub issue from a user about this, which I
  commented on today. As a result, the problem has just been
  fixed in badger and a new version will presumably make its way
  to CRAN soon.

* fusen
  checking tests ... ERROR

  This package was using `usethis::create_project(path =)` in a
  manner counter to its documentation and an internal usethis
  change broke one of their tests. I don't regard this as a
  breaking change, though, since I'm basically surprised the code
  ever worked.

  I have opened a GitHub issue, as well as a pull request with a
  1 line fix that repairs the test setup.
