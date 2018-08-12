# codemetar

Version: 0.1.6

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘memoise’
      All declared Imports should be used.
    ```

# fakemake

Version: 1.3.0

## In both

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘rcmdcheck’
    ```

# prodigenr

Version: 0.4.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘clipr’ ‘desc’ ‘devtools’
      All declared Imports should be used.
    ```

# rstantools

Version: 1.5.0

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      [32m✔[39m Creating [34m'tools/'[39m
      [32m✔[39m Creating [34m'src/'[39m
      [31m──[39m [31m1. Error: (unknown) (@test-rstan_package_skeleton.R#4) [39m [31m─────────────────────────[39m
      cannot open URL 'https://raw.githubusercontent.com/stan-dev/rstanarm/master/src/Makevars.win'
      1: rstan_package_skeleton(path = file.path(tempdir(), "testPackage"), stan_files = test_path("test.stan")) at testthat/test-rstan_package_skeleton.R:4
      2: use_rstanarm_file("src/Makevars.win")
      3: utils::download.file(url = .rstanarm_path(rstanarm_relative_path), destfile = file.path(proj, 
             rstanarm_relative_path), quiet = TRUE)
      
      ══ testthat results  ═══════════════════════════════════════════════════════════════
      OK: 42 SKIPPED: 0 FAILED: 1
      1. Error: (unknown) (@test-rstan_package_skeleton.R#4) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

