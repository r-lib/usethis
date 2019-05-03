## Test environments

* local macOS Mojave 10.14.4 + R 3.5.3 (2019-03-11)
* win-builder: devel and release
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
* travis-ci:
  - Ubuntu trusty (14.04.5 LTS)
  - devel, release, oldrel, 3.3, 3.2, 3.1
* appveyor: Windows Server 2012 + R 3.5.3 Patched (2019-03-11 r76275)

## R CMD check results

0 errors | 0 warnings | 0 notes

## revdepcheck results

We checked 28 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 1 new problem
 * We failed to check 2 packages
 
The problem seen in exampletestr is a single failing test and I believe the test just needs to be rewritten. I've corresponded with the maintainer and he'll fix
when he is back at work (in next couple weeks).

Issues with CRAN packages are summarised below.

### New problems
(This reports the first line of each new failure)

* exampletestr
  checking tests ...

### Failed to check

* POUMM
* BIOMASS

See our revdep check results at <https://github.com/r-lib/usethis/tree/master/revdep>.
