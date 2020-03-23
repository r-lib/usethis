# BiocWorkflowTools

<details>

* Version: 1.12.0
* Source code: https://github.com/cran/BiocWorkflowTools
* Date/Publication: 2019-10-29
* Number of recursive dependencies: 46

Run `revdep_details(,"BiocWorkflowTools")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘BiocWorkflowTools-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: createBiocWorkflow
    > ### Title: Create a New Bioconductor Workflow Package
    > ### Aliases: createBiocWorkflow
    > 
    > ### ** Examples
    > 
    > createBiocWorkflow(file.path(tempdir(), "MyWorkflow"), open = FALSE)
    [32m✓[39m Creating [34m'/tmp/RtmptjcKST/MyWorkflow/'[39m
    [32m✓[39m Setting active project to [34m'/private/tmp/RtmptjcKST/MyWorkflow'[39m
    [32m✓[39m Creating [34m'R/'[39m
    Error in utils::packageVersion("roxygen2") : 
      there is no package called ‘roxygen2’
    Calls: createBiocWorkflow ... build_description -> use_description_defaults -> <Anonymous>
    [32m✓[39m Setting active project to [34m'<no active project>'[39m
    Execution halted
    ```

## In both

*   checking dependencies in R code ... NOTE
    ```
    Unexported objects imported by ':::' calls:
      ‘BiocStyle:::auth_affil_latex’ ‘BiocStyle:::modifyLines’
      ‘rmarkdown:::partition_yaml_front_matter’
      See the note in ?`:::` about the use of this operator.
    ```

# cleanr

<details>

* Version: 1.3.0
* Source code: https://github.com/cran/cleanr
* URL: https://gitlab.com/fvafrCU/cleanr
* Date/Publication: 2020-01-09 21:10:02 UTC
* Number of recursive dependencies: 74

Run `revdep_details(,"cleanr")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘cleanr-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: check_package
    > ### Title: Check a Package
    > ### Aliases: check_package
    > 
    > ### ** Examples
    > 
    > # create a fake package first:
    > package_path <- file.path(tempdir(), "fake")
    > usethis::create_package(package_path, fields = NULL,
    +                         rstudio = FALSE, open = FALSE)
    [32m✓[39m Creating [34m'/tmp/RtmpRCR29o/fake/'[39m
    [32m✓[39m Setting active project to [34m'/private/tmp/RtmpRCR29o/fake'[39m
    [32m✓[39m Creating [34m'R/'[39m
    Error: [90m`fields`[39m must be a list, not [34m'NULL'[39m.
    [32m✓[39m Setting active project to [34m'<no active project>'[39m
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/runit.R’ failed.
    Last 13 lines of output:
      --------------------------- 
      Test file: /Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/cleanr/new/cleanr.Rcheck/cleanr/runit_tests/runit_throw.R 
      test_exception: (1 checks) ... OK (0 seconds)
      --------------------------- 
      Test file: /Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/cleanr/new/cleanr.Rcheck/cleanr/runit_tests/runit_utils.R 
      test_is_not_false: (10 checks) ... OK (0 seconds)
      --------------------------- 
      Test file: /Users/hadley/Documents/devtools/usethis/revdep/checks.noindex/cleanr/new/cleanr.Rcheck/cleanr/runit_tests/runit_wrappers.R 
      test_check_directory: (2 checks) ... OK (0.01 seconds)
      test_check_file: (3 checks) ... OK (0.02 seconds)
      test_check_file_layout: (2 checks) ... OK (0 seconds)
      test_check_function_layout: (2 checks) ... OK (0.01 seconds)
      test_check_functions_in_file: (2 checks) ... OK (0.04 seconds)
      Error: RUnit failed.
      Execution halted
    ```

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
      Backtrace:
        1. testthat::expect_output(...)
       10. etl::create_etl_package(path, open = FALSE)
       11. usethis::create_package(...) revdep/checks.noindex/etl/new/etl.Rcheck/00_pkg_src/etl/R/utils.R:244:2
       12. usethis::use_description(fields, check_name = FALSE, roxygen = roxygen)
       13. usethis:::build_description(name, roxygen = roxygen, fields = fields)
       14. usethis::use_description_defaults(...)
       15. utils::packageVersion("roxygen2")
      
      ══ testthat results  ══════════════════════════════════════════════════════════════════════════════
      [ OK: 27 | SKIPPED: 2 | WARNINGS: 0 | FAILED: 1 ]
      1. Error: create ETL works (@test-etl.R#114) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# hardhat

<details>

* Version: 0.1.2
* Source code: https://github.com/cran/hardhat
* URL: https://github.com/tidymodels/hardhat
* BugReports: https://github.com/tidymodels/hardhat/issues
* Date/Publication: 2020-02-28 07:20:16 UTC
* Number of recursive dependencies: 100

Run `revdep_details(,"hardhat")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      ══ testthat results  ══════════════════════════════════════════════════════════════════════════════
      [ OK: 390 | SKIPPED: 0 | WARNINGS: 4 | FAILED: 17 ]
      1. Failure: can create a modeling package (@test-use.R#11) 
      2. Failure: can create a modeling package (@test-use.R#11) 
      3. Failure: can create a modeling package (@test-use.R#21) 
      4. Failure: can create a modeling package (@test-use.R#23) 
      5. Failure: can create a modeling package (@test-use.R#24) 
      6. Failure: can create a modeling package (@test-use.R#26) 
      7. Failure: can create a modeling package (@test-use.R#27) 
      8. Failure: can create a modeling package (@test-use.R#28) 
      9. Failure: can add a second model to a modeling package (@test-use.R#40) 
      1. ...
      
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

# rstantools

<details>

* Version: 2.0.0
* Source code: https://github.com/cran/rstantools
* URL: https://mc-stan.org/rstantools/, https://discourse.mc-stan.org/
* BugReports: https://github.com/stan-dev/rstantools/issues
* Date/Publication: 2019-09-15 00:10:05 UTC
* Number of recursive dependencies: 86

Run `revdep_details(,"rstantools")` for more info

</details>

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      [90m 1. [39mrstantools::rstan_create_package(...)
      [90m 4. [39musethis::create_package(...) [90mrevdep/checks.noindex/rstantools/new/rstantools.Rcheck/00_pkg_src/rstantools/R/rstan_create_package.R:153:2[39m
      [90m 5. [39musethis::use_description(fields, check_name = FALSE, roxygen = roxygen)
      [90m 6. [39musethis:::build_description(name, roxygen = roxygen, fields = fields)
      [90m 7. [39musethis::use_description_defaults(...)
      [90m 8. [39musethis:::check_is_named_list(fields)
      [90m 9. [39musethis::ui_stop("{ui_code(nm)} must be a list, not {ui_value(bad_class)}.")
      
      ══ testthat results  ══════════════════════════════════════════════════════════════════════════════
      [ OK: 41 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 2 ]
      1. Error: (unknown) (@test-rstan_config.R#40) 
      2. Error: (unknown) (@test-rstan_create_package.R#62) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

