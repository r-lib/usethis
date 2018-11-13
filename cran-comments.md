## Test environments

* local macOS Sierra 10.12.6 + R 3.5.1
* Ubuntu trusty (14.04.5 LTS) via travis-ci, R 3.1 -> R-devel
* Windows Server 2012 + R 3.5.1 Patched (2018-08-10 r75106) via appveyor
* Windows + R Under development (unstable) (2018-08-11 r75106) via win-builder

## R CMD check results

0 errors | 0 warnings | 0 notes

## revdepcheck results

We checked 6 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

2 of 6 pass R CMD check with no NOTEs, WARNINGS, or ERRORs: testthis, uCAREChemSuiteCLI

3 of 6 have a NOTE, but the NOTE is present with both the CRAN version of usethis and the current submission (it has nothing to do with usethis): codemetar, fakemake, prodigenr

1 of 6 shows an ERROR but the ERROR is present with both the CRAN version of usethis and the current submission (it has nothing to do with usethis): rstantools

See our revdep check results at <https://github.com/r-lib/usethis/tree/master/revdep>.
