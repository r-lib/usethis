# butcher

<details>

* Version: 0.1.2
* Source code: https://github.com/cran/butcher
* URL: https://tidymodels.github.io/butcher, https://github.com/tidymodels/butcher
* BugReports: https://github.com/tidymodels/butcher/issues
* Date/Publication: 2020-01-23 22:40:02 UTC
* Number of recursive dependencies: 180

Run `revdep_details(,"butcher")` for more info

</details>

## Error before installation

### Devel

```
* using log directory ‘/tmp/workdir/butcher/new/butcher.Rcheck’
* using R version 3.6.3 (2020-02-29)
* using platform: x86_64-pc-linux-gnu (64-bit)
* using session charset: UTF-8
* using options ‘--no-manual --no-build-vignettes’
* checking for file ‘butcher/DESCRIPTION’ ... OK
* this is package ‘butcher’ version ‘0.1.2’
* package encoding: UTF-8
* checking package namespace information ... OK
* checking package dependencies ... ERROR
Package suggested but not available: ‘NMF’

The suggested packages are required for a complete check.
Checking can be attempted without them by setting the environment
variable _R_CHECK_FORCE_SUGGESTS_ to a false value.

See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
manual.
* DONE
Status: 1 ERROR






```
### CRAN

```
* using log directory ‘/tmp/workdir/butcher/old/butcher.Rcheck’
* using R version 3.6.3 (2020-02-29)
* using platform: x86_64-pc-linux-gnu (64-bit)
* using session charset: UTF-8
* using options ‘--no-manual --no-build-vignettes’
* checking for file ‘butcher/DESCRIPTION’ ... OK
* this is package ‘butcher’ version ‘0.1.2’
* package encoding: UTF-8
* checking package namespace information ... OK
* checking package dependencies ... ERROR
Package suggested but not available: ‘NMF’

The suggested packages are required for a complete check.
Checking can be attempted without them by setting the environment
variable _R_CHECK_FORCE_SUGGESTS_ to a false value.

See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
manual.
* DONE
Status: 1 ERROR






```
# finbif

<details>

* Version: 0.3.0
* Source code: https://github.com/cran/finbif
* URL: https://github.com/luomus/finbif, https://luomus.github.io/finbif
* BugReports: https://github.com/luomus/finbif/issues
* Date/Publication: 2020-04-23 11:20:02 UTC
* Number of recursive dependencies: 123

Run `revdep_details(,"finbif")` for more info

</details>

## In both

*   checking whether package ‘finbif’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/tmp/workdir/finbif/new/finbif.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘finbif’ ...
** package ‘finbif’ successfully unpacked and MD5 sums checked
** using staged installation
** R
** data
*** moving datasets to lazyload DB
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
*** copying figures
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
Error: package or namespace load failed for ‘finbif’:
 .onLoad failed in loadNamespace() for 'finbif', details:
  call: supported_langs[[l]]
  error: subscript out of bounds
Error: loading failed
Execution halted
ERROR: loading failed
* removing ‘/tmp/workdir/finbif/new/finbif.Rcheck/finbif’

```
### CRAN

```
* installing *source* package ‘finbif’ ...
** package ‘finbif’ successfully unpacked and MD5 sums checked
** using staged installation
** R
** data
*** moving datasets to lazyload DB
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
*** copying figures
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
Error: package or namespace load failed for ‘finbif’:
 .onLoad failed in loadNamespace() for 'finbif', details:
  call: supported_langs[[l]]
  error: subscript out of bounds
Error: loading failed
Execution halted
ERROR: loading failed
* removing ‘/tmp/workdir/finbif/old/finbif.Rcheck/finbif’

```
