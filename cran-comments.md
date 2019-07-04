This is a patch release with bug fixes and small features.

## Test environments

* local: macOS Mojave 10.14.4 + 3.6.0
* win-builder: devel and release
* travis: Ubuntu 14.04.5 LTS (trusty) + 3.2, 3.3, 3.4, oldrel, release, devel
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
* appveyor: Windows Server 2012 + R 3.6.0 Patched (2019-06-23 r76734)

usethis v1.5.0 is currently in ERROR on Solaris due to the lack of dependency git2r. I'm not sure what that is about, but it is beyond our control to fix. git2r itself has status OK on Solaris at the moment.

## R CMD check results

0 errors | 0 warnings | 1 note

There is 1 note about a "(possibly) invalid URL" in an Rd file. The URL is https://github.com/settings/tokens. The behaviour of this URL is reasonable when it is visited by human in the browser, whether they are logged into GitHub or not, but it to be expected that it 404s in a headless state.

## revdepcheck results

We checked 39 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package. We see no differences and, in particular, no changes for the worse.

Automated check failed for 2 packages:
  - portalr, R CMD check timed out
    I re-checked manually. It seems to hang on building vignettes and testing.
    portalr is currently in ERROR on CRAN for several platforms.
    I assume I am seeing the same problem and that it's not related to usethis.
  - POUMM, failed to install, due to openmp issues

See our automated revdep check results at <https://github.com/r-lib/usethis/tree/master/revdep>.
