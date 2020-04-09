# codemetar

<details>

* Version: 0.1.8
* Source code: https://github.com/cran/codemetar
* URL: https://github.com/ropensci/codemetar, https://ropensci.github.io/codemetar
* BugReports: https://github.com/ropensci/codemetar/issues
* Date/Publication: 2019-04-22 04:20:03 UTC
* Number of recursive dependencies: 80

Run `revdep_details(,"codemetar")` for more info

</details>

## In both

*   R CMD check timed out
    

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘memoise’
      All declared Imports should be used.
    ```

# RxODE

<details>

* Version: 0.9.2-0
* Source code: https://github.com/cran/RxODE
* URL: https://nlmixrdevelopment.github.io/RxODE/
* BugReports: https://github.com/nlmixrdevelopment/RxODE/issues
* Date/Publication: 2020-03-13 07:10:14 UTC
* Number of recursive dependencies: 132

Run `revdep_details(,"RxODE")` for more info

</details>

## In both

*   checking whether package ‘RxODE’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/RxODE/new/RxODE.Rcheck/00install.out’ for details.
    ```

*   checking package dependencies ... NOTE
    ```
    Packages suggested but not available for checking:
      'SnakeCharmR', 'installr'
    ```

## Installation

### Devel

```
* installing *source* package ‘RxODE’ ...
** package ‘RxODE’ successfully unpacked and MD5 sums checked
** using staged installation
checking for gcc... ccache /usr/local/opt/llvm/bin/clang -fopenmp -Qunused-arguments
checking whether the C compiler works... no
configure: error: in `/Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/RxODE/new/RxODE.Rcheck/00_pkg_src/RxODE':
configure: error: C compiler cannot create executables
See `config.log' for more details
ERROR: configuration failed for package ‘RxODE’
* removing ‘/Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/RxODE/new/RxODE.Rcheck/RxODE’

```
### CRAN

```
* installing *source* package ‘RxODE’ ...
** package ‘RxODE’ successfully unpacked and MD5 sums checked
** using staged installation
checking for gcc... ccache /usr/local/opt/llvm/bin/clang -fopenmp -Qunused-arguments
checking whether the C compiler works... no
configure: error: in `/Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/RxODE/old/RxODE.Rcheck/00_pkg_src/RxODE':
configure: error: C compiler cannot create executables
See `config.log' for more details
ERROR: configuration failed for package ‘RxODE’
* removing ‘/Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/RxODE/old/RxODE.Rcheck/RxODE’

```
