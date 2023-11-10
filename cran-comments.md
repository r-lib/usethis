This is a patch release in response to a 2023-06-28 email from Kurt Hornik about
inputs to numeric_version() and package_version().

In this case, the problematic inputs came from implicit usage via `>` in some
tests and these have been changed to comparison to character or removed
entirely.

I did NOT rerun reverse dependency checks because usethis's last patch release
was less than 2 weeks ago, also in response to a request from Kurt Hornik about
numeric versions.

## R CMD check results

0 errors | 0 warnings | 0 notes

## revdepcheck results

From the previous patch release on 2023-06-23:

We checked 181 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw no new problems
 * We failed to check 0 packages
