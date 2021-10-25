This patch release 2.1.3 modifies a test to ensure that intermittent GitHub rate limiting cannot lead to ungraceful failure on CRAN.

This submission, on 2021-10-25, is in direct response to an email from Professor Brian Ripley, also received on 2021-10-25, which states:

"Please correct before 2021-11-08 to safely retain your package on CRAN."

In case it comes up, the reverse dependency tidytuesdayR regularly fails when CRAN checks usethis, due to tidytuesdayR hitting a GitHub API rate limit in its tests. This is an expected false positive and has been seen on multiple previous successful usethis submissions.

Although that is the same phenomenon that I've just addressed in a usethis test, this is a coincidence. That is, the tidytuesdayR test failure due to GitHub rate limits is completely independent of that package's usage of usethis. Those GitHub calls are not routing through any usethis functions. The fragile tests were present before the recent usethis release and there's nothing I can do in usethis to fix the behaviour of their tests.

## R CMD check results

0 errors | 0 warnings | 1 note

The note is "Days since last update: 2" (see above).

## revdepcheck results

## revdepcheck results

We checked 124 reverse dependencies (123 from CRAN + 1 from Bioconductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 1 packages

Issues with CRAN packages are summarised below.

### Failed to check

* butcher (NA)

