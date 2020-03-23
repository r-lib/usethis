# DataPackageR

<details>

* Version: 0.15.7
* Source code: https://github.com/cran/DataPackageR
* URL: https://github.com/ropensci/DataPackageR
* BugReports: https://github.com/ropensci/DataPackageR/issues
* Date/Publication: 2019-03-30 17:40:03 UTC
* Number of recursive dependencies: 79

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
      cars_over_20══ testthat results  ══════════════════════════════════════════════════════════════════════════════
      [ OK: 209 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 1 ]
      1. Failure: use_ignore works (@test-ignore.R#16) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# devtools

<details>

* Version: 2.2.2
* Source code: https://github.com/cran/devtools
* URL: https://devtools.r-lib.org/, https://github.com/r-lib/devtools
* BugReports: https://github.com/r-lib/devtools/issues
* Date/Publication: 2020-02-17 20:30:02 UTC
* Number of recursive dependencies: 102

Run `revdep_details(,"devtools")` for more info

</details>

## Newly broken

*   checking for code/documentation mismatches ... WARNING
    ```
    Codoc mismatches from documentation object 'create':
    create
      Code: function(path, fields = list(), rstudio =
                     rstudioapi::isAvailable(), roxygen = TRUE, check_name
                     = TRUE, open = interactive())
      Docs: function(path, fields = NULL, rstudio =
                     rstudioapi::isAvailable(), open = interactive())
      Argument names in code not in docs:
        roxygen check_name
      Mismatches in argument names:
        Position: 4 Code: roxygen Docs: open
      Mismatches in argument default values:
        Name: 'fields' Code: list() Docs: NULL
    ```

# etl

<details>

* Version: 0.3.8
* Source code: https://github.com/cran/etl
* URL: http://github.com/beanumber/etl
* BugReports: https://github.com/beanumber/etl/issues
* Date/Publication: 2019-12-18 18:20:02 UTC
* Number of recursive dependencies: 103

Run `revdep_details(,"etl")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      
          intersect, setdiff, setequal, union
      
      > 
      > test_check("etl")
      [31m──[39m [31m1. Failure: create ETL works (@test-etl.R#114) [39m [31m────────────────────────────────────────────────[39m
      `create_etl_package\(path, open = FALSE\)` does not match "active project".
      Actual value: "Package: scorecard\\nTitle: What the Package Does \(One Line, Title Case\)\\nVersion: 0\.0\.0\.9000\\nAuthors@R \(parsed\):\\n    \* First Last <first\.last@example\.com> \[aut, cre\] \(<https://orcid\.org/YOUR-ORCID-ID>\)\\nDescription: What the package does \(one paragraph\)\.\\nLicense: `use_mit_license\(\)`, `use_gpl3_license\(\)` or friends to pick a\\n    license\\nEncoding: UTF-8\\nLazyData: true\\nRoxygen: list\(markdown = TRUE\)\\nRoxygenNote: 7\.0\.0"
      
      ══ testthat results  ══════════════════════════════════════════════════════════════════════════════
      [ OK: 27 | SKIPPED: 2 | WARNINGS: 0 | FAILED: 1 ]
      1. Failure: create ETL works (@test-etl.R#114) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# portalr

<details>

* Version: 0.3.1
* Source code: https://github.com/cran/portalr
* URL: https://weecology.github.io/portalr/, https://github.com/weecology/portalr
* BugReports: https://github.com/weecology/portalr/issues
* Date/Publication: 2020-01-16 15:00:02 UTC
* Number of recursive dependencies: 103

Run `revdep_details(,"portalr")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      Actual value: ""
      
      [31m──[39m [31m4. Failure: default data path functions work if unset (@test-01-data-retrieval.R#110) [39m [31m─────────[39m
      `m` does not match "Make sure '.Renviron' ends with a newline!".
      Actual value: ""
      
      ══ testthat results  ══════════════════════════════════════════════════════════════════════════════
      [ OK: 193 | SKIPPED: 10 | WARNINGS: 0 | FAILED: 4 ]
      1. Failure: default data path functions work if unset (@test-01-data-retrieval.R#107) 
      2. Failure: default data path functions work if unset (@test-01-data-retrieval.R#108) 
      3. Failure: default data path functions work if unset (@test-01-data-retrieval.R#109) 
      4. Failure: default data path functions work if unset (@test-01-data-retrieval.R#110) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

