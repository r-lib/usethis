## R CMD check results

0 errors | 0 warnings | 0 notes

## revdepcheck results

We checked 217 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 3 new problems
 * We failed to check 1 packages

Issues with CRAN packages are summarised below.

### New problems

* circle
  This package makes reference to a function that is now removed from usethis.
  This function has been hard-deprecated (i.e. throws an error with advice on
  how to update) since usethis v2.2.0, released in December 2020.
  I have opened an issue in circle's GitHub repository.

* exampletestr
  This package has a brittle test that checks for exact wording of an error
  message originating in usethis.
  That test fails because usethis's error message has changed slightly.
  I have opened an issue in exampletestr's GitHub repository.

* pharmaverseadam
  I saw the NOTE about the installed package size being large.
  I believe this is spurious/random as I don't see how this could be related to
  usethis.

### Failed to check

* scaper (NA)
