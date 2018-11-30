## Test environments

* local: darwin15.6.0-3.5.1
* travis: 3.1, 3.2, 3.3, oldrel, release, devel
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
* win-builder: windows-x86_64-devel

## R CMD check results

0 errors | 0 warnings | 0 notes

## revdepcheck results

We checked 6 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

2 of 6 pass R CMD check with no NOTEs, WARNINGS, or ERRORs: testthis, uCAREChemSuiteCLI

3 of 6 have a NOTE, but the NOTE is present with both the CRAN version of usethis and the current submission (it has nothing to do with usethis): codemetar, fakemake, prodigenr

1 of 6 shows an ERROR but the ERROR is present with both the CRAN version of usethis and the current submission (it has nothing to do with usethis): rstantools

See our revdep check results at <https://github.com/r-lib/usethis/tree/master/revdep>.
