# DataPackageR

<details>

* Version: 0.15.7
* Source code: https://github.com/cran/DataPackageR
* URL: https://github.com/ropensci/DataPackageR
* BugReports: https://github.com/ropensci/DataPackageR/issues
* Date/Publication: 2019-03-30 17:40:03 UTC
* Number of recursive dependencies: 105

Run `revdep_details(,"DataPackageR")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
        files:
          subsetCars.Rmd:
            enabled: yes
          extra.rmd:
            enabled: yes
        objects: cars_over_20
        render_root: dummy
      
      subsetCars.Rmd extra.rmd
      cars_over_20══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 209 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 1 ]
      1. Failure: use_ignore works (@test-ignore.R#16) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# devtools

<details>

* Version: 2.2.1
* Source code: https://github.com/cran/devtools
* URL: https://github.com/r-lib/devtools
* BugReports: https://github.com/r-lib/devtools/issues
* Date/Publication: 2019-09-24 15:00:02 UTC
* Number of recursive dependencies: 123

Run `revdep_details(,"devtools")` for more info

</details>

## Newly broken

*   checking for code/documentation mismatches ... WARNING
    ```
    Codoc mismatches from documentation object 'create':
    create
      Code: function(path, fields = NULL, rstudio =
                     rstudioapi::isAvailable(), check_name = TRUE, open =
                     interactive())
      Docs: function(path, fields = NULL, rstudio =
                     rstudioapi::isAvailable(), open = interactive())
      Argument names in code not in docs:
        check_name
      Mismatches in argument names:
        Position: 4 Code: check_name Docs: open
    ```

# portalr

<details>

* Version: 0.2.7
* Source code: https://github.com/cran/portalr
* URL: https://weecology.github.io/portalr/, https://github.com/weecology/portalr
* BugReports: https://github.com/weecology/portalr/issues
* Date/Publication: 2019-10-04 22:00:02 UTC
* Number of recursive dependencies: 121

Run `revdep_details(,"portalr")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      Actual value: ""
      
      ── 4. Failure: default data path functions work if unset (@test-01-data-retrieva
      `m` does not match "Make sure '.Renviron' ends with a newline!".
      Actual value: ""
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 174 | SKIPPED: 10 | WARNINGS: 0 | FAILED: 4 ]
      1. Failure: default data path functions work if unset (@test-01-data-retrieval.R#107) 
      2. Failure: default data path functions work if unset (@test-01-data-retrieval.R#108) 
      3. Failure: default data path functions work if unset (@test-01-data-retrieval.R#109) 
      4. Failure: default data path functions work if unset (@test-01-data-retrieval.R#110) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

