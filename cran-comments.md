In case it comes up, the reverse dependency tidytuesdayR regularly fails when CRAN checks usethis, due to tidytuesdayR hitting a GitHub API rate limit in its tests. This is an expected false positive and has been seen on multiple previous successful usethis submissions.

## revdepcheck results

We checked 153 reverse dependencies (152 from CRAN + 1 from Bioconductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 1 package (animalcules, from Bioconductor)

