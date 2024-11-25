# KMunicate

<details>

* Version: 0.2.5
* GitHub: https://github.com/ellessenne/KMunicate-package
* Source code: https://github.com/cran/KMunicate
* Date/Publication: 2024-05-16 11:50:08 UTC
* Number of recursive dependencies: 171

Run `revdepcheck::cloud_details(, "KMunicate")` for more info

</details>

## Error before installation

### Devel

```
* using log directory ‘/tmp/workdir/KMunicate/new/KMunicate.Rcheck’
* using R version 4.3.1 (2023-06-16)
* using platform: x86_64-pc-linux-gnu (64-bit)
* R was compiled by
    gcc (Ubuntu 13.2.0-23ubuntu4) 13.2.0
    GNU Fortran (Ubuntu 13.2.0-23ubuntu4) 13.2.0
* running under: Ubuntu 24.04.1 LTS
* using session charset: UTF-8
* using option ‘--no-manual’
* checking for file ‘KMunicate/DESCRIPTION’ ... OK
...
* checking for unstated dependencies in ‘tests’ ... OK
* checking tests ... OK
  Running ‘testthat.R’
* checking for unstated dependencies in vignettes ... OK
* checking package vignettes in ‘inst/doc’ ... OK
* checking running R code from vignettes ... OK
  ‘KMunicate.Rmd’ using ‘UTF-8’... OK
* checking re-building of vignette outputs ... OK
* DONE
Status: OK





```
### CRAN

```
* using log directory ‘/tmp/workdir/KMunicate/old/KMunicate.Rcheck’
* using R version 4.3.1 (2023-06-16)
* using platform: x86_64-pc-linux-gnu (64-bit)
* R was compiled by
    gcc (Ubuntu 13.2.0-23ubuntu4) 13.2.0
    GNU Fortran (Ubuntu 13.2.0-23ubuntu4) 13.2.0
* running under: Ubuntu 24.04.1 LTS
* using session charset: UTF-8
* using option ‘--no-manual’
* checking for file ‘KMunicate/DESCRIPTION’ ... OK
...
* checking for unstated dependencies in ‘tests’ ... OK
* checking tests ... OK
  Running ‘testthat.R’
* checking for unstated dependencies in vignettes ... OK
* checking package vignettes in ‘inst/doc’ ... OK
* checking running R code from vignettes ... OK
  ‘KMunicate.Rmd’ using ‘UTF-8’... OK
* checking re-building of vignette outputs ... OK
* DONE
Status: OK





```
# scaper

<details>

* Version: 0.1.0
* GitHub: NA
* Source code: https://github.com/cran/scaper
* Date/Publication: 2023-10-19 07:20:02 UTC
* Number of recursive dependencies: 161

Run `revdepcheck::cloud_details(, "scaper")` for more info

</details>

## In both

*   checking whether package ‘scaper’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/tmp/workdir/scaper/new/scaper.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘scaper’ ...
** package ‘scaper’ successfully unpacked and MD5 sums checked
** using staged installation
** R
** inst
** byte-compile and prepare package for lazy loading
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  namespace ‘Matrix’ 1.5-4.1 is already loaded, but >= 1.6.4 is required
Calls: <Anonymous> ... namespaceImportFrom -> asNamespace -> loadNamespace
Execution halted
ERROR: lazy loading failed for package ‘scaper’
* removing ‘/tmp/workdir/scaper/new/scaper.Rcheck/scaper’


```
### CRAN

```
* installing *source* package ‘scaper’ ...
** package ‘scaper’ successfully unpacked and MD5 sums checked
** using staged installation
** R
** inst
** byte-compile and prepare package for lazy loading
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  namespace ‘Matrix’ 1.5-4.1 is already loaded, but >= 1.6.4 is required
Calls: <Anonymous> ... namespaceImportFrom -> asNamespace -> loadNamespace
Execution halted
ERROR: lazy loading failed for package ‘scaper’
* removing ‘/tmp/workdir/scaper/old/scaper.Rcheck/scaper’


```
